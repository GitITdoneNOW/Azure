# This sript will pick from the provided list of names to create random accounts into the domain under the OU specified.
# Currently the script is set to create 200 random accounts with matching email addresses with random password.
# It checks for duplicates before creating the next account

# Only adjust the following (I didn't have time to set up the scipt with proper variables so look for these parameters):
## "OU=UsersRandom3,DC=ld,DC=local"
## SearchBase "DC=ld,DC=local"
## New-ADOrganizationalUnit -Name "UsersRandom3" -Path "DC=ld,DC=local"
## ($users.Count -lt 200)   <--This can be adjusted or just run the script multiple times but note that the CSV created that has the passwords will be overwritten.
## Export-Csv -Path "C:\UserList.csv"  <-- WARNING - Passwords are store in this file!!
## Import-Csv -Path "C:\UserList.csv"


# Created by Nicholas Zulli
# Created on 20240702


Import-Module ActiveDirectory

# Define the OU path
$ouPath = "OU=UsersRandom3,DC=ld,DC=local"

# Check if the OU exists
if (-not (Get-ADOrganizationalUnit -Filter { Name -eq "Users" } -SearchBase "DC=ld,DC=local" -ErrorAction SilentlyContinue)) {
    # Create the OU if it does not exist
    New-ADOrganizationalUnit -Name "UsersRandom3" -Path "DC=ld,DC=local"
}

# List of common first and last names - add more if desired
$firstNames = @(
    "John", "Jane", "Michael", "Emily", "Chris", "Sarah", "David", "Laura", "James", "Mary",
    "Robert", "Linda", "William", "Patricia", "Joseph", "Jennifer", "Charles", "Elizabeth", "Thomas", "Barbara",
    "Joshua", "Nancy", "Daniel", "Karen", "Matthew", "Margaret", "Anthony", "Lisa", "Donald", "Betty",
    "Paul", "Sandra", "Mark", "Ashley", "George", "Kimberly", "Steven", "Donna", "Kenneth", "Carol",
    "Andrew", "Michelle", "Kevin", "Dorothy", "Brian", "Amanda", "Edward", "Melissa", "Ronald", "Deborah",
    "Timothy", "Stephanie", "Jason", "Rebecca", "Jeffrey", "Sharon", "Ryan", "Laura", "Jacob", "Cynthia",
    "Gary", "Kathleen", "Nicholas", "Amy", "Eric", "Angela", "Jonathan", "Shirley", "Stephen", "Anna",
    "Larry", "Brenda", "Justin", "Pamela", "Scott", "Emma", "Brandon", "Nicole", "Frank", "Helen",
    "Benjamin", "Samantha", "Gregory", "Katherine", "Raymond", "Christine", "Samuel", "Debra", "Patrick", "Rachel",
    "Alexander", "Catherine", "Jack", "Carolyn", "Dennis", "Janet", "Jerry", "Heather", "Tyler", "Maria",
    "Aaron", "Diane", "Henry", "Julie", "Douglas", "Joyce", "Peter", "Victoria", "Jose", "Megan",
    "Adam", "Cheryl", "Zachary", "Martha", "Nathan", "Andrea", "Walter", "Frances", "Harold", "Hannah",
    "Kyle", "Jacqueline", "Carl", "Ann", "Arthur", "Gloria", "Gerald", "Jean", "Roger", "Kathryn",
    "Keith", "Alice", "Jeremy", "Teresa", "Terry", "Sara", "Lawrence", "Janice", "Sean", "Doris",
    "Christian", "Julia", "Albert", "Madison", "Joe", "Grace", "Ethan", "Judy", "Austin", "Theresa",
    "Jesse", "Beverly", "Willie", "Denise", "Billy", "Marilyn", "Bryan", "Amber", "Bruce", "Danielle",
    "Jordan", "Rose", "Ralph", "Brittany", "Roy", "Diana", "Noah", "Natalie", "Dylan", "Sophia",
    "Eugene", "Alexis", "Wayne", "Lori", "Alan", "Kayla", "Juan", "Jane", "Louis", "Olivia",
    "Russell", "Tiffany", "Gabriel", "Phyllis", "Randy", "Courtney", "Vincent", "Holly", "Philip", "Joan",
    "Bobby", "Christina", "Johnny", "Teresa", "Howard", "Lauren", "Bradley", "Marie", "Curtis", "Ann",
    "Louis", "Carol", "Bruce", "Darlene", "Eugene", "Ruth", "Wayne", "Betty", "Jordan", "Jessica",
    "Ralph", "Alice", "Kyle", "Beverly", "Juan", "Ashley", "Alan", "Nicole", "Russell", "Emily",
    "Johnny", "Samantha", "Howard", "Kimberly", "Gerald", "Michelle", "Philip", "Deborah", "Billy", "Rebecca",
    "Ethan", "Melissa", "Joe", "Nancy", "Shawn", "Katherine", "Albert", "Victoria", "Henry", "Margaret",
    "Arthur", "Cheryl", "Stephen", "Catherine", "Carl", "Stephanie", "Lawrence", "Janet", "Alex", "Kathleen",
    "Patrick", "Julia", "Harold", "Frances", "Jeremy", "Diane", "Walter", "Joyce", "Terry", "Martha",
    "Douglas", "Angela", "Sean", "Ann", "Jesse", "Susan", "Peter", "Brenda", "Zachary", "Sharon",
    "Jerry", "Judith", "Dennis", "Laura", "Paul", "Marilyn", "Bruce", "Cynthia", "Randy", "Diana",
    "Bryan", "Kelly", "Adam", "Wanda", "Henry", "Virginia", "Jack", "Jacqueline", "Scott", "Leslie",
    "Justin", "Kathryn", "Benjamin", "Jean", "Timothy", "Megan", "Steven", "Theresa", "Christopher", "Lori",
    "Gary", "Linda", "Joshua", "Carolyn", "Eric", "Amanda", "Frank", "Megan", "Tyler", "Cathy",
    "Philip", "Beverly", "Gabriel", "Frances", "Billy", "Alice", "Bryan", "Helen", "Jesse", "Janet",
    "Nathan", "Ruth", "Larry", "Heather", "Ralph", "Teresa", "Christian", "Diane", "Henry", "Dorothy",
    "Walter", "Brenda", "Stephen", "Janice", "Arthur", "Patricia", "Terry", "Kathleen", "Albert", "Virginia",
    "Lawrence", "Ashley", "Timothy", "Sara", "Adam", "Kathy", "Matthew", "Jean", "Charles", "Sandra",
    "Alex", "Margaret", "Thomas", "Carol", "Mark", "Kim", "Nicholas", "Laura", "Ryan", "Debra",
    "James", "Rebecca", "Andrew", "Shirley", "Kevin", "Denise", "Daniel", "Gloria", "Brian", "Ann",
    "Michael", "Barbara", "Joseph", "Marie", "David", "Theresa", "William", "Doris", "Robert", "Alice",
    "John", "Helen", "Richard", "Marilyn", "Thomas", "Pamela", "Christopher", "Janice", "Daniel", "Joan",
    "Paul", "Sandra", "Donald", "Beverly", "Ronald", "Catherine", "Kenneth", "Phyllis", "George", "Carolyn",
    "Kevin", "Julia", "Edward", "Megan", "Mark", "Frances", "Steven", "Katherine", "Stephen", "Theresa",
    "Joseph", "Christina", "Larry", "Marilyn", "Patrick", "Jean", "Eric", "Ann", "Gregory", "Kathy",
    "Nicholas", "Shirley", "Jacob", "Brenda", "Jonathan", "Diane", "Aaron", "Laura", "Andrew", "Nancy",
    "Joshua", "Beverly", "Jordan", "Helen", "Brian", "Sandra", "Justin", "Ann", "Ryan", "Carol",
    "Tyler", "Rebecca", "Benjamin", "Kathleen", "Alexander", "Jean", "James", "Sharon", "Robert", "Carolyn",
    "William", "Diane", "Michael", "Kimberly", "David", "Megan", "Richard", "Julia", "Charles", "Angela",
    "Christopher", "Janice", "Joseph", "Frances", "Matthew", "Ann", "Joshua", "Jean", "Nicholas", "Rebecca",
    "Ryan", "Diane", "Andrew", "Shirley", "James", "Kathleen", "Daniel", "Beverly", "David", "Megan",
    "William", "Helen", "Christopher", "Sandra", "Matthew", "Carol", "James", "Kathleen", "Daniel", "Beverly", 
    "John", "Jane", "Michael", "Emily", "Chris", "Sarah", "David", "Laura", "James", "Mary",
    "Robert", "Linda", "William", "Patricia", "Joseph", "Jennifer", "Charles", "Elizabeth", "Thomas", "Barbara",
    "Joshua", "Nancy", "Daniel", "Karen", "Matthew", "Margaret", "Anthony", "Lisa", "Donald", "Betty",
    "Paul", "Sandra", "Mark", "Ashley", "George", "Kimberly", "Steven", "Donna", "Kenneth", "Carol",
    "Andrew", "Michelle", "Kevin", "Dorothy", "Brian", "Amanda", "Edward", "Melissa", "Ronald", "Deborah",
    "Timothy", "Stephanie", "Jason", "Rebecca", "Jeffrey", "Sharon", "Ryan", "Laura", "Jacob", "Cynthia",
    "Gary", "Kathleen", "Nicholas", "Amy", "Eric", "Angela", "Jonathan", "Shirley", "Stephen", "Anna",
    "Larry", "Brenda", "Justin", "Pamela", "Scott", "Emma", "Brandon", "Nicole", "Frank", "Helen",
    "Benjamin", "Samantha", "Gregory", "Katherine", "Raymond", "Christine", "Samuel", "Debra", "Patrick", "Rachel",
    "Alexander", "Catherine", "Jack", "Carolyn", "Dennis", "Janet", "Jerry", "Heather", "Tyler", "Maria",
    "Aaron", "Diane", "Henry", "Julie", "Douglas", "Joyce", "Peter", "Victoria", "Jose", "Megan",
    "Adam", "Cheryl", "Zachary", "Martha", "Nathan", "Andrea", "Walter", "Frances", "Harold", "Hannah",
    "Kyle", "Jacqueline", "Carl", "Ann", "Arthur", "Gloria", "Gerald", "Jean", "Roger", "Kathryn",
    "Keith", "Alice", "Jeremy", "Teresa", "Terry", "Sara", "Lawrence", "Janice", "Sean", "Doris",
    "Christian", "Julia", "Albert", "Madison", "Joe", "Grace", "Ethan", "Judy", "Austin", "Theresa",
    "Jesse", "Beverly", "Willie", "Denise", "Billy", "Marilyn", "Bryan", "Amber", "Bruce", "Danielle",
    "Jordan", "Rose", "Ralph", "Brittany", "Roy", "Diana", "Noah", "Natalie", "Dylan", "Sophia",
    "Eugene", "Alexis", "Wayne", "Lori", "Alan", "Kayla", "Juan", "Jane", "Louis", "Olivia",
    "Russell", "Tiffany", "Gabriel", "Phyllis", "Randy", "Courtney", "Vincent", "Holly", "Philip", "Joan",
    "Bobby", "Christina", "Johnny", "Teresa", "Howard", "Lauren", "Bradley", "Marie", "Curtis", "Ann",
    "Louis", "Carol", "Bruce", "Darlene", "Eugene", "Ruth", "Wayne", "Betty", "Jordan", "Jessica",
    "Ralph", "Alice", "Kyle", "Beverly", "Juan", "Ashley", "Alan", "Nicole", "Russell", "Emily",
    "Johnny", "Samantha", "Howard", "Kimberly", "Gerald", "Michelle", "Philip", "Deborah", "Billy", "Rebecca",
    "Ethan", "Melissa", "Joe", "Nancy", "Shawn", "Katherine", "Albert", "Victoria", "Henry", "Margaret",
    "Arthur", "Cheryl", "Stephen", "Catherine", "Carl", "Stephanie", "Lawrence", "Janet", "Alex", "Kathleen",
    "Patrick", "Julia", "Harold", "Frances", "Jeremy", "Diane", "Walter", "Joyce", "Terry", "Martha",
    "Douglas", "Angela", "Sean", "Ann", "Jesse", "Susan", "Peter", "Brenda", "Zachary", "Sharon",
    "Jerry", "Judith", "Dennis", "Laura", "Paul", "Marilyn", "Bruce", "Cynthia", "Randy", "Diana",
    "Bryan", "Kelly", "Adam", "Wanda", "Henry", "Virginia", "Jack", "Jacqueline", "Scott", "Leslie",
    "Justin", "Kathryn", "Benjamin", "Jean", "Timothy", "Megan", "Steven", "Theresa", "Christopher", "Lori",
    "Gary", "Linda", "Joshua", "Carolyn", "Eric", "Amanda", "Frank", "Megan", "Tyler", "Cathy",
    "Philip", "Beverly", "Gabriel", "Frances", "Billy", "Alice", "Bryan", "Helen", "Jesse", "Janet",
    "Nathan", "Ruth", "Larry", "Heather", "Ralph", "Teresa", "Christian", "Diane", "Henry", "Dorothy",
    "Walter", "Brenda", "Stephen", "Janice", "Arthur", "Patricia", "Terry", "Kathleen", "Albert", "Virginia",
    "Lawrence", "Ashley", "Timothy", "Sara", "Adam", "Kathy", "Matthew", "Jean", "Charles", "Sandra",
    "Alex", "Margaret", "Thomas", "Carol", "Mark", "Kim", "Nicholas", "Laura", "Ryan", "Debra",
    "James", "Rebecca", "Andrew", "Shirley", "Kevin", "Denise", "Daniel", "Gloria", "Brian", "Ann",
    "Michael", "Barbara", "Joseph", "Marie", "David", "Theresa", "William", "Doris", "Robert", "Alice",
    "John", "Helen", "Richard", "Marilyn", "Thomas", "Pamela", "Christopher", "Janice", "Daniel", "Joan",
    "Paul", "Sandra", "Donald", "Beverly", "Ronald", "Catherine", "Kenneth", "Phyllis", "George", "Carolyn",
    "Kevin", "Julia", "Edward", "Megan", "Mark", "Frances", "Steven", "Katherine", "Stephen", "Theresa",
    "Joseph", "Christina", "Larry", "Marilyn", "Patrick", "Jean", "Eric", "Ann", "Gregory", "Kathy",
    "Nicholas", "Shirley", "Jacob", "Brenda", "Jonathan", "Diane", "Aaron", "Laura", "Andrew", "Nancy",
    "Joshua", "Beverly", "Jordan", "Helen", "Brian", "Sandra", "Justin", "Ann", "Ryan", "Carol",
    "Tyler", "Rebecca", "Benjamin", "Kathleen", "Alexander", "Jean", "James", "Sharon", "Robert", "Carolyn",
    "William", "Diane", "Michael", "Kimberly", "David", "Megan", "Richard", "Julia", "Charles", "Angela",
    "Christopher", "Janice", "Joseph", "Frances", "Matthew", "Ann", "Joshua", "Jean", "Nicholas", "Rebecca",
    "Ryan", "Diane", "Andrew", "Shirley", "James", "Kathleen", "Daniel", "Beverly", "David", "Megan",
    "William", "Helen", "Christopher", "Sandra", "Matthew", "Carol", "James", "Kathleen", "Daniel", "Beverly"
)
 
$lastNames = @(
    "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", 
    "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", 
    "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", 
    "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", 
    "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins", 
    "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey", 
    "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez", 
    "James", "Watson", "Brooks", "Kelly", "Sanders",
    "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell",
    "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant",
    "Alexander", "Russell", "Griffin", "Diaz", "Hayes", "Myers", "Ford", "Hamilton", "Graham", "Sullivan",
    "Wallace", "Woods", "Cole", "West", "Jordan", "Owens", "Reynolds", "Fisher", "Ellis", "Harrison",
    "Gibson", "Mcdonald", "Cruz", "Marshall", "Ortiz", "Gomez", "Murray", "Freeman", "Wells", "Webb",
    "Simpson", "Stevens", "Tucker", "Porter", "Hunter", "Hicks", "Crawford", "Henry", "Boyd", "Mason",
    "Morales", "Kennedy", "Warren", "Dixon", "Ramos", "Reyes", "Burns", "Gordon", "Shaw", "Holmes",
    "Rice", "Robertson", "Hunt", "Black", "Daniels", "Palmer", "Mills", "Nichols", "Grant", "Knight",
    "Ferguson", "Rose", "Stone", "Hawkins", "Dunn", "Perkins", "Hudson", "Spencer", "Gardner", "Stephens",
    "Payne", "Pierce", "Berry", "Matthews", "Arnold", "Wagner", "Willis", "Ray", "Watkins", "Olson",
    "Carroll", "Duncan", "Snyder", "Hart", "Cunningham", "Bradley", "Lane", "Andrews", "Ruiz", "Harper",
    "Fox", "Riley", "Armstrong", "Carpenter", "Weaver", "Greene", "Lawrence", "Elliott", "Chavez", "Sims",
    "Austin", "Peters", "Kelley", "Franklin", "Lawson", "Fields", "Gutierrez", "Ryan", "Schmidt", "Carr",
    "Vasquez", "Castillo", "Wheeler", "Chapman", "Oliver", "Montgomery", "Richards", "Williamson", "Johnston", "Banks",
    "Meyer", "Bishop", "Mccoy", "Howell", "Alvarez", "Morrison", "Hansen", "Fernandez", "Garza", "Harvey",
    "Little", "Burton", "Stanley", "Nguyen", "George", "Jacobs", "Reid", "Kim", "Fuller", "Lynch",
    "Dean", "Gilbert", "Garrett", "Romero", "Welch", "Larson", "Frazier", "Burke", "Hanson", "Day",
    "Mendoza", "Moreno", "Bowman", "Medina", "Fowler", "Brewer", "Hoffman", "Carlson", "Silva", "Pearson",
    "Holland", "Douglas", "Fleming", "Jensen", "Vargas", "Byrd", "Davidson", "Hopkins", "May", "Terry",
    "Herrera", "Wade", "Soto", "Walters", "Curtis", "Neal", "Caldwell", "Lowe", "Jennings", "Barnett",
    "Graves", "Jimenez", "Horton", "Shelton", "Barrett", "Obrien", "Castro", "Sutton", "Gregory", "Mckinney",
    "Lucas", "Miles", "Craig", "Rodriquez", "Chambers", "Holt", "Lambert", "Fletcher", "Watts", "Bates",
    "Hale", "Rhodes", "Pena", "Beck", "Newman", "Haynes", "Mcdaniel", "Mendez", "Bush", "Vaughn",
    "Parks", "Dawson", "Santiago", "Norris", "Hardy", "Love", "Steele", "Curry", "Powers", "Schultz",
    "Barker", "Guzman", "Page", "Munoz", "Ball", "Keller", "Chandler", "Weber", "Leonard", "Walsh",
    "Lyons", "Ramsey", "Wolfe", "Schneider", "Mullins", "Benson", "Sharp", "Bowen", "Daniel", "Barber",
    "Cummings", "Hines", "Baldwin", "Griffith", "Valdez", "Hubbard", "Salazar", "Reeves", "Warner", "Stevenson",
    "Burgess", "Santos", "Tate", "Cross", "Garner", "Mann", "Mack", "Moss", "Thornton", "Dennis",
    "Mcgee", "Farmer", "Delgado", "Aguilar", "Vega", "Glover", "Manning", "Cohen", "Harmon", "Rodgers",
    "Robbins", "Newton", "Todd", "Blair", "Higgins", "Ingram", "Reese", "Cannon", "Strickland", "Townsend",
    "Potter", "Goodwin", "Walton", "Rowe", "Hampton", "Ortega", "Patton", "Swanson", "Joseph", "Francis",
    "Goodman", "Maldonado", "Yates", "Becker", "Erickson", "Hodges", "Rios", "Conner", "Adkins", "Webster",
    "Norman", "Malone", "Hammond", "Flowers", "Cobb", "Moody", "Quinn", "Blake", "Maxwell", "Pope",
    "Floyd", "Osborne", "Paul", "Mccarthy", "Guerrero", "Lindsey", "Estrada", "Sandoval", "Gibbs", "Tyler",
    "Gross", "Fitzgerald", "Stokes", "Doyle", "Sherman", "Saunders", "Wise", "Colon", "Gill", "Alvarado",
    "Greer", "Padilla", "Simon", "Waters", "Nunez", "Ballard", "Schwartz", "Mcbride", "Houston", "Christensen",
    "Klein", "Pratt", "Briggs", "Parsons", "Mclaughlin", "Zimmerman", "French", "Buchanan", "Moran", "Copeland",
    "Roy", "Pittman", "Brady", "Mccormick", "Holloway", "Brock", "Poole", "Frank", "Logan", "Owen",
    "Bass", "Marsh", "Drake", "Wong", "Jefferson", "Park", "Morton", "Abbott", "Sparks", "Patrick",
    "Norton", "Huff", "Clayton", "Massey", "Lloyd", "Figueroa", "Carson", "Bowers", "Roberson", "Barton",
    "Tran", "Lamb", "Harrington", "Casey", "Boone", "Cortez", "Clarke", "Mathis", "Singleton", "Wilkins",
    "Cain", "Bryan", "Underwood", "Hogan", "Mckenzie", "Collier", "Luna", "Phelps", "Mcguire", "Allison",
    "Bridges", "Wilkerson", "Nash", "Summers", "Atkins", "Wilcox", "Pitts", "Conley", "Marquez", "Burnett",
    "Richard", "Cameron", "Kirk", "Gates", "Clay", "Ayala", "Sawyer", "Roman", "Vazquez", "Dickerson",
    "Hodge", "Acosta", "Flynn", "Espinoza", "Nicholson", "Monroe", "Wolf", "Morrow", "Kirkpatrick", "Blevins",
    "Stark", "Schaefer", "Rosales", "Horton", "Holden", "Tang", "Hussein", "Patel", "Gupta", "Singh",
    "Yamamoto", "Kimura", "Takashi", "Sato", "Hasegawa", "Matsumoto", "Suzuki", "Watanabe", "Nakamura", "Kobayashi",
    "Fernandes", "Silva", "Ribeiro", "Costa", "Oliveira", "Santos", "Araujo", "Sousa", "Pereira", "Gomes",
    "Chen", "Wang", "Li", "Zhang", "Liu", "Huang", "Yang", "Zhao", "Wu", "Xu",
    "Kowalski", "Nowak", "Kwiatkowski", "Kaminski", "Lewandowski", "Zielinski", "Szymanski", "Wojcik", "Kozlowski", "Jankowski",
    "Ivanov", "Smirnov", "Kuznetsov", "Popov", "Sokolov", "Lebedev", "Morozov", "Petrov", "Volkov", "Solovyev",
    "Garcia", "Gonzalez", "Rodriguez", "Fernandez", "Lopez", "Martinez", "Perez", "Sanchez", "Ramirez", "Torres",
    "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner", "Becker", "Hoffmann", "Schulz", "Koch",
    "Novak", "Horvat", "Kovac", "Vukovic", "Popovic", "Jovanovic", "Nikolic", "Ilic", "Todorovic", "Pavlovic",
    "Davies", "Evans", "Thomas", "Roberts", "Johnson", "Lewis", "Walker", "Robinson", "Wood", "Thompson"
)


# Function to generate a random password
function Generate-RandomPassword {
    $length = 12
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?/~"
    $password = -join ((65..90) + (97..122) + (48..57) + (33..47) + (58..64) | Get-Random -Count $length | ForEach-Object { [char]$_ })
    return $password
}

$users = @()

while ($users.Count -lt 200) {
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random
    $username = $firstName.Substring(0,1).ToLower() + $lastName.ToLower()
    $email = $username + "@ld.local"
    
    # Check if the user already exists in AD
    if (-not (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue)) {
        $password = Generate-RandomPassword
        
        $user = New-Object PSObject -Property @{
            FirstName = $firstName
            LastName = $lastName
            Username = $username
            Email = $email
            Password = $password
        }
        $users += $user
    }
}

$users | Export-Csv -Path "C:\UserList.csv" -NoTypeInformation

# Import users from CSV and create them in AD
$users = Import-Csv -Path "C:\UserList.csv"

foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $username = $user.Username
    $password = $user.Password
    $email = $user.Email

    # Check if the user already exists in AD before creation
    if (-not (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue)) {
        New-ADUser -Name "$firstName $lastName" `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -SamAccountName $username `
                   -UserPrincipalName $email `
                   -EmailAddress $email `
                   -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
                   -PasswordNeverExpires $true `
                   -Enabled $true `
                   -Path $ouPath
    }
}
