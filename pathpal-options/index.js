const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendFollowerNotification = functions.firestore
    .document('followers/{followedUid}/{followerUid}')
    .onUpdate(async (change, context) => {
        const followerUid = context.params.followerUid;
        const followedUid = context.params.followedUid;
        
        // 팔로우 상태가 유지되는지 확인 (null이면 언팔로우)
        if (!change.after.exists) {
            return functions.logger.log(
                'User ',
                followerUid,
                'un-followed user',
                followedUid
            );
        }

        // 새로운 팔로우 상태를 로깅
        functions.logger.log(
            'We have a new follower UID:',
            followerUid,
            'for user:',
            followedUid
        );

        // 팔로우된 사용자의 토큰 목록을 가져옴
        const getDeviceTokensPromise = admin.firestore()
            .doc(`/voul/${followedUid}`).get();

        // 팔로워의 프로필을 가져옴
        const getFollowerProfilePromise = admin.auth().getUser(followerUid);

        const results = await Promise.all([getDeviceTokensPromise, getFollowerProfilePromise]);
        const followedDoc = results[0];
        const follower = results[1];

        // 토큰을 체크
        if (!followedDoc.exists || !followedDoc.data().notificationTokens) {
            return functions.logger.log('There are no notification tokens to send to.');
        }
        const tokens = followedDoc.data().notificationTokens;

        // 알림 메시지 설정
        const payload = {
            notification: {
                title: 'You have a new follower!',
                body: `${follower.displayName} is now following you.`,
                icon: follower.photoURL
            }
        };

        // 알림을 모든 토큰에 보냄
        const response = await admin.messaging().sendToDevice(tokens, payload);

        // 실패한 토큰 처리
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
                functions.logger.error(
                    'Failure sending notification to',
                    tokens[index],
                    error
                );
                // 등록되지 않은 토큰 삭제
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                    tokensToRemove.push(admin.firestore().doc(`/users/${followedUid}/notificationTokens/${tokens[index]}`).delete());
                }
            }
        });

        return Promise.all(tokensToRemove);
    });
