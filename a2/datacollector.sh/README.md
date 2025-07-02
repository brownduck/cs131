This file runs a shell script that automates the unzipping and processing of data when given a url and numerical columns as input.

To run the shell script, go to the directory that holds dataset.sh (great name). Then, execute it with ./dataset.sh . You will be prompted to enter a URL with data, so use this one for now: https://archive.ics.uci.edu/static/public/186/wine+quality.zip
If you are not prompted and the program exits, you might need unzip installed, so do sudo apt install unzip (for unzipping stuff).
After your data has been extracted, it will prompt what columns you want to display in the summary. Enter in numbers, separated by commas without spaces (eg. 0,1,2,3,4,5).
Once done, the original CSV's are taketh away and you are left with the summaries directory, holding the processed data.
Initial step:
![image](https://github.com/user-attachments/assets/eaa4dcff-55df-407f-94bc-25ed6dbdb09f)
Entering columns:
![image](https://github.com/user-attachments/assets/90c2130a-6a7f-484d-841e-3c7f17357a2a)
Final displayed result of the summary file:
![image](https://github.com/user-attachments/assets/ed61d7d1-30cf-433e-bb1f-a4950cf64a71)


