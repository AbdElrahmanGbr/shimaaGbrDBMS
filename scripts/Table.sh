#!/bin/bash
createTable(){
    echo "==========================="
    echo "Available Tables in $dbName are : "
    ls $dbname
    echo "==========================="
    #reading table name from user
    echo -e "Table Name: \c"
    read tableName
        if [[ -f $tableName ]]; then
        echo "table already existed ,choose another name"
        tablesMenu
    fi
    #condition for empty entry
    if [[ -z "$tableName" ]]
    then
    echo "Inputs cannot be blank please try again"
    tablesMenu
    #condition for spaces after char
    elif [[ $tableName == *[[:space:]]* ]]
then
	echo "Table name can not contain spaces"
	tablesMenu
    #condition to make sure my database/dir startes with alphapitical char then follow up with anything (not containing spaces taking $1)
    elif ! [[ $tableName =~ ^[a-zA-Z]*[a-zA-Z0-9_]$ ]]  
then
    echo "Table name MUST start with Alpha char and can't start or endup with symbols except _"
	tablesMenu
else
    touch $tableName
    fi
    #reading num of col (row range)
    echo -e "Number of Columns: \c"
    read colsNum
    counter=1
    sep="|"
    rSep="\n"
    pKey=""
    #defining meta data header for meta file (.$tablename)
    metaData="Field"$sep"Type"$sep"key"
    #filling meta data (Field|type|key(if it is PK))
    while [ $counter -le $colsNum ]
    do
        echo -e "Name of Column No.$counter: \c"
        read colName
        
        echo -e "Type of Column $colName: "
        select var in "int" "str"
        do
            case $var in
                int ) colType="int";break;;
                str ) colType="str";break;;
                * ) echo "Wrong Choice" ;;
            esac
        done
        #defining which col is PK
        if [[ $pKey == "" ]]; then
            echo -e "Make PrimaryKey ? "
            select var in "yes" "no"
            do
                case $var in
                    yes ) pKey="PK";
                        metaData+=$rSep$colName$sep$colType$sep$pKey;
                    break;;
                    no )
                        metaData+=$rSep$colName$sep$colType$sep""
                    break;;
                    * ) echo "Wrong Choice" ;;
                esac
            done
        else
        #storing meta data anyways (after picking my PK)
            metaData+=$rSep$colName$sep$colType$sep""
        fi
        #checking if while is done after setting meta data (passing colnames in main table)
        #counter = 1 (my index i) , colsNum = num of cols from user
        if [[ $counter == $colsNum ]]; then
        #end of line (row)
            temp=$temp$colName
        else
        #still filling the line (row with colnames)
            temp=$temp$colName$sep
        fi
        #increasing counter (index) to continue the while loop
        ((counter++))
    done
    #creating tables (to append meta data in .tablename and colnames in tablename) files
    touch .$tableName
    #after the meta data main header Field|Type|pk(if we picked it)
    echo -e $metaData  >> .$tableName
    touch $tableName
    echo -e $temp >> $tableName
    #checking for exit status 0 = true, anything 1:255 errors
    if [[ $? == 0 ]]
    then
        echo "Table Created Successfully"
        tablesMenu
    else
        echo "Error Creating Table $tableName"
        tablesMenu
    fi
}

dropTable() {
    echo "==========================="
    echo "Available Tables in $dbName are : "
    ls $dbname
    echo "==========================="
    echo -e "Enter Table Name: \c"
    read tName
        if [[ -f $tName ]]; then
    select choice in "Remove?" "Cancel?" "Go to Tables Menu"
    do 
    case $choice in
        "Remove?") rm $tName .$tName ; echo "Table Dropped Successfully";tablesMenu ;; 
        "Cancel?") echo "Cancelled"; tablesMenu;;
        "Go to Tables Menu") tablesMenu ;;
    esac
    done
    else
    echo "Table Doesn't Exist!"
    fi
    tablesMenu
}

# #################################

insert() {
    echo "==========================="
    echo "Available Tables in $dbName are : "
    ls $dbname
    echo "==========================="
    echo -e "Table Name: \c"
    read tableName
    if ! [[ -f $tableName ]]; then
        echo "Table $tableName doesn't exist ,choose another Table"
        tablesMenu
    fi
    colsNum=`awk 'END{print NR}' .$tableName`
    sep="|"
    rSep="\n"
    #i = 2 because we have a header
    for (( i = 2; i <= $colsNum; i++ )); do
        colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
        colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
        colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
        echo -e "$colName ($colType) = \c"
        read data
        
        # Validate Input
        if [[ $colType == "int" ]]; then
            while ! [[ $data =~ ^[0-9]*$ ]]; do
                echo -e "invalid DataType !!"
                echo -e "$colName ($colType) = \c"
                read data
            done
        fi
        
        if [[ $colKey == "PK" ]]; then
            while [[ true ]]; do
            #checking for pk in current NR and previous rows (if i created the col as PK)
                if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
                    echo -e "invalid input for Primary Key !!"
                else
                    break;
                fi
                echo -e "$colName ($colType) = \c"
                read data
                if [[ $colType == "int" ]]; then
                    #validation for int data not equal extended regex (starting with digit or more)
                    while ! [[ $data =~ ^[0-9]*$ ]]; do
                        echo -e "invalid DataType !!"
                        echo -e "$colName ($colType) = \c"
                        read data
                    done
                fi
            done
        fi
        
        #Setting row
        if [[ $i == $colsNum ]]; then
        #rSep = \n
            row=$row$data$rSep
        else
            row=$row$data$sep
        fi
    done
    echo -e $row"\c" >> $tableName
    if [[ $? == 0 ]]
    then
        echo "Data Inserted Successfully"
    else
        echo "Error Inserting Data into Table $tableName"
    fi
    #initializing new row for the while loop
    row=""
    tablesMenu
}
# ####################################

updateTable() {
    echo -e "Enter Table Name: \c"
    read tName
    echo -e "Enter Column name to update : \c"
    read field
    fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
    if [[ $fid == "" ]]
    then
        echo "Not Found"
        tablesMenu
    else
        echo -e "Enter Condition Value: \c"
        read val
        res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
        if [[ $res == "" ]]
        then
            echo "Value Not Found"
            tablesMenu
        else
            echo -e "Enter FIELD name to set: \c"
            read setField
            setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tName)
            if [[ $setFid == "" ]]
            then
                echo "Not Found"
                tablesMenu
            else
                echo -e "Enter new Value to set: \c"
                read newValue
                NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tName 2>>./.error.log)
                oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tName 2>>./.error.log)
                echo $oldValue
                sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tName 2>>./.error.log
                echo "Row Updated Successfully"
                tablesMenu
            fi
        fi
    fi
}
# ###################################################

deleteFromTable() {
    echo -e "Enter Table Name: \c"
    read tName
    echo -e "Enter Condition Column name: \c"
    read field
    fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
    if [[ $fid == "" ]]
    then
        echo "Not Found"
        tablesMenu
    else
        echo -e "Enter Condition Value: \c"
        read val
        res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
        if [[ $res == "" ]]
        then
            echo "Value Not Found"
            tablesMenu
        else
            NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
            sed -i ''$NR'd' $tName 2>>./.error.log
            echo "Row Deleted Successfully"
            tablesMenu
        fi
    fi
}

#####################################################

selectAll() {
    echo -e "Enter Table Name: \c"
    read tName
    column -t -s '|' $tName 2>>./.error.log
    if [[ $? != 0 ]]
    then
        echo "Error Displaying Table $tName"
    fi
    selectMenu
}

####################################################

selectCol() {
    echo -e "Enter Table Name: \c"
    read tName
    echo -e "Enter Column Number: \c"
    read colNum
    awk 'BEGIN{FS="|"}{print $'$colNum'}' $tName
    selectMenu
}
########################################################

allCond() {
    echo -e "Select all columns from TABLE Where FIELD(OPERATOR)VALUE \n"
    echo -e "Enter Table Name: \c"
    read tName
    echo -e "Enter required FIELD name: \c"
    read field
    fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
    if [[ $fid == "" ]]
    then
        echo "Not Found"
        selectCon
    else
        echo -e "\nSupported Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
        read op
        if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
        then
            echo -e "\nEnter required VALUE: \c"
            read val
            res=$(awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|')
            if [[ $res == "" ]]
            then
                echo "Value Not Found"
                selectCon
            else
                awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|'
                selectCon
            fi
        else
            echo "Unsupported Operator\n"
            selectCon
        fi
    fi
}

################################################
specCond() {
    echo -e "Select specific column from TABLE Where FIELD(OPERATOR)VALUE \n"
    echo -e "Enter Table Name: \c"
    read tName
    echo -e "Enter required FIELD name: \c"
    read field
    fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
    if [[ $fid == "" ]]
    then
        echo "Not Found"
        selectCon
    else
        echo -e "\nSupported Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
        read op
        if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
        then
            echo -e "\nEnter required VALUE: \c"
            read val
            res=$(awk 'BEGIN{FS="|"; ORS="\n"}{if ($'$fid$op$val') print $'0'}' $tName 2>>./.error.log |  column -t -s '|')
            if [[ $res == "" ]]
            then
                echo "Value Not Found"
                selectCon
            else
                awk 'BEGIN{FS="|"; ORS="\n"}{if ($'$fid$op$val') print $'0'}' $tName 2>>./.error.log |  column -t -s '|'
                selectCon
            fi
        else
            echo "Unsupported Operator\n"
            selectCon
        fi
    fi
}






