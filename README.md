# 2024 Hackathon to solve social problems [PATHPAL]
<img width="1226" alt="pathpal" src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/b9c7229f-c69a-4dfc-a7bd-5499e6766dc1">

## 📢 Introduction
People with disabilities often face significant challenges in their daily transportation, not only due to inadequate facilities but also a lack of necessary information. PathPal is a pioneering initiative aimed at addressing this critical issue of mobility and information accessibility.

We selected this project to highlight the urgent need for comprehensive solutions to these transportation challenges. PathPal represents our commitment to enhance both physical mobility and information accessibility for people with disabilities through community service and technology.

Offering a platform where volunteers can provide safe transportation and walking assistance, PathPal hopes to significantly ease the daily mobility challenges faced by these individuals and bridge the information gap.

## 👥 Member
| [<img src="https://github.com/ej070961.png">](https://github.com/ej070961) | [<img src="https://github.com/Changha-dev.png">](https://github.com/Changha-dev) | [<img src="https://github.com/gumchinjun.png">](https://github.com/gumchinjun) | [<img src="https://github.com/ljs7143.png">](https://github.com/ljs7143) |
|:---:|:---:|:---:|:---:
이은지|전창하|전준석|이준서

## 📱 App Demo

### 📌 DisabledPerson

<table style="width: 100%;">
  <tr>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/f18cc049-3d45-4e47-a6c3-b8ea249c13c7" alt="Image 1" style="width: 100%;">
      <p>Car Service</p>
    </td>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/95817b35-6ee6-4c0e-9491-74682620fff5" alt="Image 2" style="width: 100%;">
      <p>Walking Service</p>
    </td>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/b4e30a96-b604-437d-93a2-02732520b0bd" alt="Image 3" style="width: 100%;">
      <p>ChatBot Service</p>
    </td>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/8f12d35c-d26f-4d8b-9e99-616bf7f5eb0f" alt="Image 4" style="width: 100%;">
      <p>Review Service</p>
    </td>
  </tr>
</table>

### 📌 Volunteer

<table style="width: 100%;">
  <tr>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/984984fc-4fc7-40f2-ae14-389b82b2ac90" alt="Image 1" style="width: 100%;">
      <p>Car Service</p>
    </td>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/c371e2f9-bda8-44e1-b7d9-f0ff4ced3915" alt="Image 2" style="width: 100%;">
      <p>Walking Service</p>
    </td>
    <td style="text-align: center;">
      <img src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/b25d9e4c-18d5-487b-a3de-a490e0c40c4c" alt="Image 3" style="width: 100%;">
      <p>Review Service</p>
    </td>
  </tr>
</table>

## 📋 Architecture
<img width="1032" alt="스크린샷 2024-02-17 오후 10 23 40" src="https://github.com/GDSC-TEAM-1-PathPal/.github/assets/68684425/a78dfe7c-12f2-4ee0-aabc-6499b84ff042">

 - FrontEnd
   - The app was developed using Flutter.
   - The Google Maps platform was used to utilize the map API.
- BackEnd
  - Firebase was used for app data storage and management.
    - Google login was facilitated through the use of Authentication.
    - Firestore was used to manage user and other data.
  - **Flask Server**  
    - The Flask server is designed to handle HTTP requests and responses between the client and server through the implementation of REST APIs.
    - Flask acts as the backend for the chatbot service, receiving questions from users, processing them through appropriate logic, and then returning 
- DeepLearning
  - Chatbot service incorporates a Flask server, Langchain and OpenAI technologies. Below are the details of the technologies used: 
responses.<br/>
  - **Langchain & OpenAI**  
    - A toolkit for building NLP pipelines, enabling seamless integration of data loading, processing, search, and generation tasks into a unified process.
    - Retrieval-Augmented Generation (RAG): Develop search-based methods to find highly relevant information for a given query—specifically targeting facilities
      for people with disabilities from a CSV dataset, using ChromaDB for efficient data embedding in vector space.
    - The answers are generated using OpenAI's gpt-3.5-turbo model, based on the results retrieved.  


## ❓ How To Use 

### DisabledPerson

<hr>

### 🚘 Car Service

You can request assistance by selecting your desired destination. Set your departure time, starting point, and destination.

### 🚶‍♂️ Walking Service

Select the location where you need assistance. You can send a request by entering the location, time, and details of the assistance needed.

### 🤖 ChatBot Service

There are times when you're curious about where disabled convenience facilities are located. You can find the answer using the chatbot service.

### 🫶 Review Service

You can leave a thank you note for the volunteers who helped you. Share your warm feelings with a star rating!

### Volunteer

<hr>

### 🚘 Car Service

You can check the list of people who need help. Select an item you can volunteer for, set the arrival time, and accept the request.

### 🚶‍♂️ Walking Service

You can check the markers of people who need help nearby. Select a marker, set the arrival time, and accept the request.

### 🫶 Review Service

You can check the reviews from those who expressed their gratitude. Read the content and take pride in your good work!

<hr>

## 🤝 Contributing

If you would like to contribute to PathPal, please fork the project on GitHub and submit a pull request.

