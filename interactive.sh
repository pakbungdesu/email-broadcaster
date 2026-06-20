# function
get_all_emails() {
    # 1. Check if file exists
    if [ ! -f "subscribers.csv" ]; then
        whiptail --msgbox "Error: subscribers.csv does not exist." 0 0
        return 1
    fi


    # 2. Check if file is empty
    if [ ! -s "subscribers.csv" ]; then
        whiptail --msgbox "Error: subscribers.csv is empty." 0 0
        return 1
    fi

    # 3. Extract first column (emails)
    result=$(cut -d '|' -f 1 subscribers.csv 2>/dev/null)

    # 4. Check if cut gave any result
    if [ -n "$result" ]; then
        whiptail --msgbox --title "All emails" "$result" 0 0
    else
        whiptail --msgbox "Error: No emails found in file." 0 0
        return 1
    fi
}


edit_email(){
  # 1. Check if file exists
  if [ ! -f "subscribers.csv" ]; then
    whiptail --msgbox "Error: subscribers.csv does not exist." 0 0
    return 1
  fi

  old_email="$(whiptail --inputbox "Enter Old Email Address" 0 0 "$USER" 3>&1 1>&2 2>&3)"
  [ $? -ne 0 ] && return 1   # user pressed Cancel

  new_email="$(whiptail --inputbox "Enter New Email Address" 0 0 "$USER" 3>&1 1>&2 2>&3)"
  [ $? -ne 0 ] && return 1   # user pressed Cancel

  # 2. Check if email exists in file
  if grep -q "^$old_email|" subscribers.csv; then
      sed -i "s/^$old_email|/$new_email|/" subscribers.csv
      whiptail --msgbox "Email updated: $old_email -> $new_email" 0 0
  else
      whiptail --msgbox "Email not found: $old_email" 0 0
      return 1
  fi 
}

delete_email() {
  # 1. Check if file exists
  if [ ! -f "subscribers.csv" ]; then
    whiptail --msgbox "Error: subscribers.csv does not exist." 0 0
    return 1
  fi

  email="$(whiptail --inputbox "Enter Email Address" 0 0 "$USER" 3>&1 1>&2 2>&3)"
  [ $? -ne 0 ] && return 1   # user pressed Cancel

  # 2. Check if email exists in file
  if grep -q "^$email|" subscribers.csv; then
    sed -i "/^$email|/d" subscribers.csv
    whiptail --msgbox "Email deleted: $email" 0 0
  else
    whiptail --msgbox "Email not found: $email" 0 0
    return 1
  fi
}

add_new_email() {
  address="$(whiptail --inputbox "Enter Email Address" 0 0 "$USER" 3>&1 1>&2 2>&3)"
  [ $? -ne 0 ] && return 1   # user pressed Cancel

  subject="$(whiptail --inputbox "Enter Email Subject" 0 0 "" 3>&1 1>&2 2>&3)"
  [ $? -ne 0 ] && return 1

  body="$(whiptail --inputbox "Enter Email Body" 0 0 "" 3>&1 1>&2 2>&3)"
  [ $? -ne 0 ] && return 1

  category=$(whiptail \
    --radiolist "Select Category" 0 0 4 \
    "Personal" "" 1 \
    "Work" "" 0 \
    "Marketing" "" 0 \
    "Newsletter" "" 0 \
    3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return 1

  # 1. Empty fields
  if [ -z "$address" ] || [ -z "$subject" ] || [ -z "$body" ] || [ -z "$category" ]; then
    whiptail --msgbox "Error: All fields must be filled." 0 0
    return 1
  fi

  # 2. Prevent duplicate email
  if grep -q "^$address|" subscribers.csv 2>/dev/null; then
    whiptail --msgbox "Error: Email already exists." 0 0
    return 1
  fi

  # --- If everything is OK, save ---
  printf "%s|%s|%s|%s\n" "$address" "$subject" "$body" "$category" >> "subscribers.csv"
  whiptail --msgbox --title "Add New Email" "Email added: $address" 0 0
}


# main
result=$(whiptail \
  --menu "Email Scheduler" 0 0 5 \
  "1." "Add New Email" \
  "2." "View All Emails" \
  "3." "Edit Email"\
  "4." "Delete Email"\
  "5." "Exit"\
  3>&1 1>&2 2>&3)

case $result in
  "1.")
    add_new_email
    ;;
  "2.")
    get_all_emails
    ;;
  "3.")
    edit_email
    ;;
  "4.")
    delete_email
    ;;
  "5.")
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac