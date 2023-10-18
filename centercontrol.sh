#!/usr/bin/bash
if [[ ! -e "status" ]];then # if status not exist , initialize one
    echo "1" > "status"
fi
menu () { 
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Menu
    1.Start from the beginning 
    2.Continue from the current STEP $(cat status) (Recommand)
    3.Choose specific STEP
    4.exit
    5.print manul
    6.reset status
    "
    read -p "Please input your choice: " choice
    
    echo "----------------------------------------------------------------------------------------------------------"
}

echo "----------------------------------------------------------------------------------------------------------"
echo "Welcome to the centercontrol system!
We have totally 6 STEPS for this ICA1 Task "
echo "Checking status : $(cat status)"
if [[ $(cat status) == "1" ]];then
    echo "We are now in the STEP 1"
else
    echo "We went to STEP $(cat status) last time"
fi
read -n1 -sp "Press any key to continue......"
echo

while true;do
    menu
    case $choice in
        1)  
            execute_num=1 ;;
        2) 
            execute_num=$(cat status) ;;
        3) 
            read -p "Which STEP do u want execute?" execute_num ;;
        4) 
            exit ;;
        5) 
            echo manul 
            continue ;;
        6)
            rm -f status 
            exit;;
        *) 
            echo "Wrong command , input again"  
            continue ;;
    esac
    echo "We are going to run STEP$(cat status)"
    read -p "Do you sure you want to execute it (y/n):" double_check
    case $double_check in
        y)
            ./script"$execute_num"_* ;;
        *)
            echo "Undo"
            continue ;;
    esac
    while true ; do
        echo "----------------------------------------------------------------------------------------------------------"
        read -p "Is the current STEP program sucessful,if there is NO error please input y?(y/n):" status_add
        case $status_add in
            y)  
                status_num=$(cat status)
                echo "Move to next STEP "
                ((status_num+=1))
                echo "$status_num">status
                break ;;
            n)
                echo "Let's run again"
                break ;;
            *)  
                echo "Wrong command, input again";;
        esac
    done
    if [[ "$status_num" == 7 ]];then
        rm -f status
        echo "----------------------------------------------------------------------------------------------------------"
        echo "Program finished! Thank you for using!"
        exit
    fi
done

