#!/bin/bash
#\c to keep me in line
source scripts/Database.sh
source scripts/Table.sh
#checking for dir existence
if ! [[ -e databases ]]; then
    mkdir databases 2>> ./.error.log
fi
# mkdir databases 2>> ./.error.log
clear
echo "Welcome To Our DBMS!"
function mainMenu {
    echo -e "\n+-----------Main Menu---------------+"
    echo "| 1. Select Database                |"
    echo "| 2. Create Database                |"
    echo "| 3. Rename Database                |"
    echo "| 4. Drop Database                  |"
    echo "| 5. Show Databases                 |"
    echo "| 6. Exit                           |"
    echo "+-----------------------------------+"
    echo -e "Enter Choice: \c"
    read ch
    case $ch in
        1)  selectDB ;;
        2)  createDB ;;
        3)  renameDB ;;
        4)  dropDB ;;
        5)  ls ./databases ; mainMenu;;
        6) exit ;;
        *) echo " Wrong Choice " ; mainMenu;
    esac
}

function selectDB {
    echo "==========================="
    echo "Available Databases are : "
    ls ./databases
    echo "==========================="
    echo -e "Enter Database Name: \c"
    read dbName
    selectDatabase $dbName
    if [[ $? == 0 ]]; then
        tablesMenu
    else
        mainMenu
    fi
}

function createDB {
    echo "==========================="
    echo "Available Databases are : "
    ls ./databases
    echo "==========================="
    echo -e "Enter Database Name: \c"
    read dbName
    #condition for empty entry
    if [[ -z "$dbName" ]]
    then
    echo "Inputs cannot be blank please try again"
    createDB
    #condition for spaces after char
elif [[ $dbName == *[[:space:]]* ]]
then
	echo "database name can not contain spaces"
	createDB
#condition to make sure my database/dir startes with alphapitical char then follow up with anything (not containing spaces taking $1)
    elif ! [[ $dbName =~ +([a-zA-Z]*[a-zA-Z0-9_]) ]]  
then
    echo "Database MUST start with Alpha char and can't start or endup with symbols except _"
	createDB
else
    createDatabase $dbNames
    mainMenu
    fi
}

function renameDB {
    echo "==========================="
    echo "Available Databases are : "
    ls ./databases
    echo "==========================="
    echo -e "Enter Current Database Name: \c"
    read dbName
    if [[ -d ./databases/$dbName ]]
    then 
    echo -e "Enter New Database Name: \c"
    read newName
    #condition for empty entry
    if [[ -z "$newName" ]]
    then
    echo "Inputs cannot be blank please try again"
    renameDB
#condition for spaces after char
    elif [[ $newName == *[[:space:]]* ]]
then
	echo "database name can not contain spaces"
	renameDB
    elif ! [[ $newName =~ +([a-zA-Z_]*[a-zA-Z0-9_]) ]]  
then
    echo "Database MUST start with Alpha char and can't start or endup with symbols except _"
	renameDB
else
renameDatabase $dbName $newName
    mainMenu
    fi 
    else 
    echo "database not found"
    renameDB
    fi
}

function dropDB {
    echo "==========================="
    echo "Available Databases are : "
    ls ./databases
    echo "==========================="
    echo -e "Enter Database Name: \c"
    read dbName
    dropDatabase $dbName
    mainMenu
}

function tablesMenu {
    echo -e "\n+--------Tables Menu------------+"
    echo "| 1. Show Existing Tables       |"
    echo "| 2. Create New Table           |"
    echo "| 3. Insert Into Table          |"
    echo "| 4. Select From Table          |"
    echo "| 5. Update Table               |"
    echo "| 6. Delete From Table          |"
    echo "| 7. Drop Table                 |"
    echo "| 8. Back To Main Menu          |"
    echo "| 9. Exit                       |"
    echo "+-------------------------------+"
    echo -e "Enter Choice: \c"
    read ch
    case $ch in
        1)  ls .; tablesMenu ;;
        2)  createTable ;;
        3)  insert ;;
        4)  clear; selectMenu ;;
        5)  updateTable ;;
        6)  deleteFromTable;;
        7)  dropTable;;
        8) clear; cd ../.. 2>>./.error.log; mainMenu ;;
        9) exit ;;
        *) echo " Wrong Choice " ; tablesMenu;
    esac
    
}


function selectMenu {
    echo -e "\n\n+---------------Select Menu--------------------+"
    echo "| 1. Select All Columns of a Table              |"
    echo "| 2. Select Specific Column from a Table        |"
    echo "| 3. Select From Table under condition          |"
    echo "| 4. Back To Tables Menu                        |"
    echo "| 5. Back To Main Menu                          |"
    echo "| 6. Exit                                       |"
    echo "+----------------------------------------------+"
    echo -e "Enter Choice: \c"
    read ch
    case $ch in
        1) selectAll ;;
        2) selectCol ;;
        3) clear; selectCon ;;
        4) clear; tablesMenu ;;
        5) clear; cd ../.. 2>>./.error.log; mainMenu ;;
        6) exit ;;
        *) echo " Wrong Choice " ; selectMenu;
    esac
}

function selectCon {
    echo -e "\n\n+--------Select Under Condition Menu-----------+"
    echo "| 1. Select All Columns Matching Condition    |"
    echo "| 2. Select Specific Column Matching Condition|"
    echo "| 3. Back To Selection Menu                   |"
    echo "| 4. Back To Main Menu                        |"
    echo "| 5. Exit                                     |"
    echo "+---------------------------------------------+"
    echo -e "Enter Choice: \c"
    read ch
    case $ch in
        1) clear; allCond ;;
        2) clear; specCond ;;
        3) clear; selectMenu ;;
        4) clear; cd ../.. 2>>./.error.log; mainMenu ;;
        5) exit ;;
        *) echo " Wrong Choice " ; selectCon;
    esac
}

mainMenu
