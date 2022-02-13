#!/bin/bash -x

createDatabase(){
    mkdir ./databases/$dbName
    if [[ $? == 0 ]]
    then
        echo "Database Created Successfully"
        return 0
    else
        echo "Error Creating Database $dbName"
        return 1
    fi
}

selectDatabase(){
  dbName=$1
  cd ./databases/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo "Database $dbName was Successfully Selected"
    return 0
  else
    echo "Database $dbName wasn't found"
    return 1
  fi
}

renameDatabase(){
    dbName=$1; newName=$2
    if [[ -d databases/$newName ]];
then
	echo "DataBase already exists!"
	echo "Enter another valid name!"
    renameDB
else
    mv ./databases/$dbName ./databases/$newName 2>>./.error.log
        echo "Database Updated Successfully"
    fi
}

dropDatabase(){
    select choice in "Remove?" "Cancel?" "Go to MainMenu"
    do 
    case $choice in
        "Remove?") rm -r ./databases/$dbName ; echo "Database Dropped Successfully";mainMenu ;; 
        "Cancel?") echo "Cancelled"; mainMenu;;
        "Go to MainMenu") mainMenu ;;
    esac
    done
}