#include <iostream>
#include <ctime>
#include <cstdlib>
#include <string>
#include <thread>
#include <chrono>
#include <iomanip>
#include <mutex>
#include <vector>
#include <algorithm>
#include <fstream>

using namespace std;

int score = 0;
int timeLeft = 60; // 60 seconds timer
int wrongGuesses = 0;
string chosenCharacter;
mutex mtx;
vector<int> highScores;

void displayTimer() {
    while (timeLeft > 0) {
        this_thread::sleep_for(chrono::seconds(1));
        timeLeft--;
        mtx.lock();
        cout << "\033[s"; // Save cursor position
        cout << "\033[H"; // Move cursor to top-left corner
        cout << "=============================" << endl;
        cout << "|| Time left: " << setw(2) << timeLeft << " seconds ||" << endl;
        cout << "|| Score: " << setw(10) << score << " ||" << endl;
        cout << "=============================" << endl;
        cout << "\033[u"; // Restore cursor position
        mtx.unlock();
    }
    mtx.lock();
    cout << "\nTime's up! Your final score is: " << score << endl;
    highScores.push_back(score);
    sort(highScores.rbegin(), highScores.rend());
    cout << "High Scores:" << endl;
    for (int i = 0; i < min(5, (int)highScores.size()); i++) {
        cout << i + 1 << ". " << highScores[i] << endl;
    }
    mtx.unlock();
    exit(0);
}

int doomsdayAlgorithm(int year, int month, int day) {
    int anchorDays[] = { 2, 0, 5, 3 }; // Anchor days for centuries: 1700s, 1800s, 1900s, 2000s
    int century = year / 100;
    int anchorDay = anchorDays[(century - 17) % 4];
    int y = year % 100;
    int doomsday = (y + y / 4 + anchorDay) % 7;

    int monthDoomsday[] = { 0, 3, 0, 4, 2, 5, 0, 3, 6, 1, 4, 6 }; // Doomsday for each month
    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        monthDoomsday[0] = 4; // Adjust for leap year
        monthDoomsday[1] = 1;
    }

    int dayOfWeek = (doomsday + (day - monthDoomsday[month - 1])) % 7;
    if (dayOfWeek < 0) dayOfWeek += 7;
    return dayOfWeek;
}
string getDayOfWeek(int dayOfWeek) {
    switch (dayOfWeek) {
        case 0: return "Sunday"; break;
        case 1: return "Monday"; break;
        case 2: return "Tuesday"; break;
        case 3: return "Wednesday"; break;
        case 4: return "Thursday"; break;
        case 5: return "Friday"; break;
        case 6: return "Saturday"; break;
        default: return "Invalid day"; break;
    }
}

void giveHint(int year, int month, int day) {
    int correctDayOfWeek = doomsdayAlgorithm(year, month, day);
    string correctAnswer = getDayOfWeek(correctDayOfWeek);

    if (chosenCharacter == "Rude Rick") {
        cout << "Rude Rick: You really need a hint? Fine. The correct day is " << correctAnswer << ". Try to remember it!" << endl;
    } else {
        cout << "Sweet Sally: Don't worry, you'll get it next time! Here's a hint: The correct day is " << correctAnswer << "." << endl;
    }
}

// Function to print colored text
void printColoredText(const string& text, const string& colorCode) {
    cout << "\033[" << colorCode << "m" << text << "\033[0m" << endl;
}

// Function to simulate a delay
void delay(int seconds) {
    this_thread::sleep_for(chrono::seconds(seconds));
}

void tutorial() {
    int score = 0;
    string chosenCharacter = "Rude Rick"; // or "Sweet Sally"

    cout << "Welcome to the Doomsday Algorithm Tutorial!" << endl;
    cout << "Let's learn how to determine the day of the week for any given date." << endl;

    int year = 2023, month = 10, day = 10; // Example date: October 10, 2023

    cout << "Step 1: Find the anchor day for the century." << endl;
    cout << "For the 2000s, the anchor day is Tuesday (2)." << endl;
    cout << "What is the anchor day for the 2000s? (Enter the day of the week)" << endl;
    string answer;
    cin >> answer;

    if (answer != "Tuesday") {
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: Seriously? It's Tuesday! Do you even know what a day is?", "31");
        } else {
            printColoredText("Sweet Sally: Oops! It's actually Tuesday. Don't worry, you'll get it!", "32");
        }
    } else {
        score += 10;
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: Finally, you got it right! Took you long enough!", "31");
        } else {
            printColoredText("Sweet Sally: Great job! You're doing well!", "32");
        }
    }

    cout << "Step 2: Calculate the doomsday for the year." << endl;
    cout << "For the year 2023, the doomsday is calculated as follows:" << endl;
    cout << "y = 23 (last two digits of the year)" << endl;
    cout << "doomsday = (y + y/4 + anchorDay) % 7" << endl;
    cout << "doomsday = (23 + 23/4 + 2) % 7 = 5 (Friday)" << endl;
    cout << "What is the doomsday for the year 2023? (Enter the day of the week)" << endl;
    cin >> answer;

    if (answer != "Friday") {
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: Wrong again! It's Friday. Are you even trying?", "31");
        } else {
            printColoredText("Sweet Sally: Almost there! The correct answer is Friday. Keep going!", "32");
        }
    } else {
        score += 10;
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: About time you got it right!", "31");
        } else {
            printColoredText("Sweet Sally: Excellent! You're getting the hang of it!", "32");
        }
    }

    cout << "Step 3: Find the doomsday for the month." << endl;
    cout << "For October, the doomsday is October 10." << endl;
    cout << "What is the doomsday for October? (Enter the day of the month)" << endl;
    cin >> answer;

    if (answer != "10") {
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: No, it's 10. Do you need glasses?", "31");
        } else {
            printColoredText("Sweet Sally: Close! The correct answer is 10. You're doing great!", "32");
        }
    } else {
        score += 10;
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: Finally, some progress!", "31");
        } else {
            printColoredText("Sweet Sally: Perfect! You're on a roll!", "32");
        }
    }

    cout << "Step 4: Calculate the day of the week for the given date." << endl;
    cout << "For October 10, 2023, the day of the week is calculated as follows:" << endl;
    cout << "dayOfWeek = (doomsday + (day - monthDoomsday)) % 7" << endl;
    cout << "dayOfWeek = (5 + (10 - 10)) % 7 = 5 (Friday)" << endl;
    cout << "What is the day of the week for October 10, 2023? (Enter the day of the week)" << endl;
    cin >> answer;

    if (answer != "Friday") {
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: Wrong again! It's Friday. Are you even trying?", "31");
        } else {
            printColoredText("Sweet Sally: Almost! The correct answer is Friday. You're doing great, keep practicing!", "32");
        }
    } else {
        score += 10;
        if (chosenCharacter == "Rude Rick") {
            printColoredText("Rude Rick: Finally, you got it right! Took you long enough!", "31");
        } else {
            printColoredText("Sweet Sally: Fantastic! You've got it! Well done!", "32");
        }
    }

    cout << "Congratulations! You've completed the tutorial." << endl;
    cout << "Your final score is: " << score << endl;
    if (chosenCharacter == "Rude Rick") {
        printColoredText("Rude Rick: Now go and try not to mess up in the real game!", "31");
    } else {
        printColoredText("Sweet Sally: You're ready for the game! Good luck and have fun!", "32");
    }
}

void playGame() {
    while (timeLeft > 0) {
        int year = rand() % 201 + 1900; // Random year between 1900 and 2100
        int month = rand() % 12 + 1; // Random month between 1 and 12
        int day = rand() % 28 + 1; // Random day between 1 and 28 (to simplify)

        mtx.lock();
        cout << "\nWhat day of the week was " << month << "/" << day << "/" << year << "?" << endl;
        cout << "Enter the number corresponding to the day (0: Sunday, 1: Monday, ..., 6: Saturday): ";
        mtx.unlock();
        int answer;
        cin >> answer;

     //   int correctDayOfWeek = doomsdayAlgorithm(year, month, day);
       // string correctAnswer = getDayOfWeek(correctDayOfWeek);
       
       int correctDayOfWeek = doomsdayAlgorithm(year, month, day);

        if (answer == correctDayOfWeek) {
            score += 10;
            wrongGuesses = 0;
            mtx.lock();
            cout << "\033[32mCorrect! Your score is: " << score << "\033[0m" << endl; // Green text for correct answer
            mtx.unlock();
        } else {
            score -= 5;
            timeLeft -= 5; // Decrease time by 5 seconds for wrong answer
            wrongGuesses++;
            mtx.lock();
            cout << "\033[31mWrong! Your score is: " << score << "\033[0m" << endl; // Red text for wrong answer
            mtx.unlock();

            if (wrongGuesses >= 2) {
                mtx.lock();
                cout << "Do you want a hint? (yes/no)" << endl;
                mtx.unlock();
                string hintResponse;
                cin >> hintResponse;
                if (hintResponse == "yes") {
                    giveHint(year, month, day);
                    wrongGuesses = 0;
                }
            } else {
                if (chosenCharacter == "Rude Rick") {
                    mtx.lock();
                    cout << "Rude Rick: Come on, you can do better than that!" << endl;
                    mtx.unlock();
                } else {
                    mtx.lock();
                    cout << "Sweet Sally: Keep trying, you'll get it!" << endl;
                    mtx.unlock();
                }
            }
        }
    }
}

void chooseCharacter() {
    cout << "Choose your character:" << endl;
    cout << "1. Rude Rick" << endl;
    cout << "2. Sweet Sally" << endl;
    cout << "3. Cool Carl" << endl; // New character
    cout << "4. Happy Hannah" << endl; // New character
    int choice;
    cin >> choice;
    if (choice == 1) {
        chosenCharacter = "Rude Rick";
    } else if (choice == 2) {
        chosenCharacter = "Sweet Sally";
    } else if (choice == 3) {
        chosenCharacter = "Cool Carl";
    } else {
        chosenCharacter = "Happy Hannah";
    }
    cout << "You chose " << chosenCharacter << "!" << endl;
}

void howToPlay() {
    cout << "How to Play:" << endl;
    cout << "1. You will be given a random date." << endl;
    cout << "2. Your task is to determine the day of the week for that date." << endl;
    cout << "3. You can use the Doomsday Algorithm to find the day of the week." << endl;
    cout << "4. If you get stuck, you can ask for a hint." << endl;
    cout << "5. Try to get as many correct answers as possible before time runs out." << endl;
    cout << "Would you like to go through the tutorial? (yes/no)" << endl;
    string response;
    cin >> response;
    if (response == "yes") {
        tutorial();
    }
}

void saveHighScores() {
    ofstream outFile("highscores.txt");
    for (int score : highScores) {
        outFile << score << endl;
    }
    outFile.close();
}

void loadHighScores() {
    ifstream inFile("highscores.txt");
    int score;
    while (inFile >> score) {
        highScores.push_back(score);
    }
    inFile.close();
}

int main() {
    srand(time(0));
    cout << "Welcome to the Doomsday Algorithm Game!" << endl;

    loadHighScores();
    howToPlay();
    chooseCharacter();

    thread timerThread(displayTimer);
    playGame();

    timerThread.join();
    saveHighScores();
    return 0;
}
