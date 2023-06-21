# Nasheville_Housing_project

The purpose of this project was to clean data from a  Nasheville housing csv file, and standardize it in SQL Server Management Studio. 
The steps I took to do this are below:

  1. create a database instance in SQL Server for project
  2. upload csv to database
  3. standardize date format
  4. populate nulls values for rows that have empty property address
  5. Split address into city, state, and address
  6. change Y and N to Yes and No in SoldAsVacant column
  7. remove duplicates(only did for this project, better to seperate duplicates into another table for professional projects)
  8. remove unused columns
