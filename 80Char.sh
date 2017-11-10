#/bin/bash

file=""

d_flag=0	# whether -d flag was passed
e_flag=0	# whether -e flag was passed
f_flag=0	# whether -f flag was passed

ext='.'		# default value for variable denoting extension
dir='.'		# default value for variable denoting target directory

while getopts ":d:e:f:" opt; do
  case $opt in
    d)
      dir=$OPTARG
      d_flag=1
      ;;
    e)
      ext=$OPTARG
      e_flag=1
      ;;
    f)
      file=$OPTARG
      f_flag=1
      ;;
    \?) 
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Make sure that the -f flag is never used with any other flags
if [[ $f_flag -eq 1 && $d_flag -eq 1 ]]; then
  echo "Cannot specify both -d or -f flags." >&2
  exit 1
elif [[ $f_flag -eq 1 && $e_flag -eq 1 ]]; then
  echo "Cannot specify both -e or -f flags." >&2
  exit 1
fi

violations=0

# Meat of the -f flag logic
if [[ $f_flag -eq 1 ]]; then 

  if [ ! -f file ]; then
    echo "Only pass in files when using the -f flag."
    exit 1
  fi

  status=`grep -H -n '.\{81,\}' "$file"`

  if [ $? -eq 0 ]; then
    if [[ $violations -eq 0 ]]; then 
      echo
      echo "VIOLATIONS FOUND:"
      echo
    fi
    
    echo $status
  fi

  violations=1

# Meat of the -d (default) and -e logic
else


  for file_to_check in `find -d $dir | grep "$ext"`
  do
    if [ -f $file_to_check ]; then
      status=""
      status=`grep --binary-files=without-match -H -n '.\{81,\}' "$file_to_check"`

      if [ $? -eq 0 ]; then
        if [[ $violations -eq 0 ]]; then 
          echo
          echo "VIOLATIONS FOUND:"
          echo
        fi

        violations=1
        echo $status
        echo		# for \n, not very readable output right now 
      fi
    fi
  done
fi

if [[ $violations -eq 0 ]]; then
  echo "None of the given files contain lines over 80 characters."
fi
