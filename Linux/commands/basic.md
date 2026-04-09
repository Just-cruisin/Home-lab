# LS
Lists current files and folders in the current directory
Flags
-a: show hidden files
-l: display details

# Find
Used to search for files
E.g. find /home “Tom.txt”
Flags
-name: exact name (case sensitive)
-iname: find by name (case sensitive)
*.txt: only find .txt files
-type d: find only directories
-type f: find only files
-mtime -7: find only files modified in the last 7 days
-size +10M: find only files larger than 10MB
-empty: find only empty files
-perm 664: find field with specific permissions

# Tree
Displays the directory structure in a tree like format
Stat
Used to display metadata about files and file systems
Stat filename provides:
File name, type and size
Device 
Permissions and links
Owner UID/ Gid
Timestamps

# Grep
Used to find lines in plane text data
Grep [OPTIONS] PATTERN [FILE…]
Grep “error” log.txt
Flags
-i: ignore case
-v: invert match (displays lines that do not match
-n: shows the line numbers of the matching output
-w: Matches only whole words
-c: counts the number of matches
-r: recursive: Searches through all files in the current directory and subdirectory

# Sed
Used to basic text transformations and manipulations on an input stream. Unlike nano or vim, operates automatically without requiring user intervention
e.g.
sed 's/test/test1/' file.txt: replaces the fiest test on each line

# Awk
Used to extract info from an input.
e.g. awk 'NR==2 {print $5}'
Outputs the value in the second row, 5th column
Flags
NR = New row

# tr
Translate values. 
e.g. tr -d '%': Deletes % from the provided value
echo "hello" | tr 'a-z' 'A-Z', gives HELLO

Cut
Sort
Uniq
