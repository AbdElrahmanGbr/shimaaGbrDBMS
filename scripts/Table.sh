#!/bin/bash
createTable(){
    echo -e "Table Name: \c"
    read tableName
    if [[ -f $tableName ]]; then
        echo "table already existed ,choose another name"
        tablesMenu
    fi
    echo -e "Number of Columns: \c"
    read colsNum
    counter=1
    sep="|"
    rSep="\n"
    pKey=""
    metaData="Field"$sep"Type"$sep"key"
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
            metaData+=$rSep$colName$sep$colType$sep""
        fi
        if [[ $counter == $colsNum ]]; then
            temp=$temp$colName
        else
            temp=$temp$colName$sep
        fi
        ((counter++))
    done
    touch .$tableName
    echo -e $metaData  >> .$tableName
    touch $tableName
    echo -e $temp >> $tableName
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
    echo -e "Enter Table Name: \c"
    read tName
    rm $tName .$tName 2>>./.error.log
    if [[ $? == 0 ]]
    then
        echo "Table Dropped Successfully"
    else
        echo "Error Dropping Table $tName"
    fi
    tablesMenu
}

# #################################

insert() {
    echo -e "Table Name: \c"
    read tableName
    if ! [[ -f $tableName ]]; then
        echo "Table $tableName isn't existed ,choose another Table"
        tablesMenu
    fi
    colsNum=`awk 'END{print NR}' .$tableName`
    sep="|"
    rSep="\n"
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
                if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
                    echo -e "invalid input for Primary Key !!"
                else
                    break;
                fi
                echo -e "$colName ($colType) = \c"
                read data
                if [[ $colType == "int" ]]; then
                    while ! [[ $data =~ ^[0-9]*$ ]]; do
                        echo -e "invalid DataType !!"
                        echo -e "$colName ($colType) = \c"
                        read data
                    done
                fi
            done
        fi
        
        #Set row
        if [[ $i == $colsNum ]]; then
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
    row=""
    tablesMenu
}
# ####################################

updateTable() {
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






