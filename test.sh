#!/bin/bash

declare -i bNotOperator=0	# for inversion of permission query
declare signValue           # for use in this module only
declare permission          # for use in this module only
declare nopermission        # for use in this module only
declare fileName
declare dirName

##############################################################################
# function isIntegerEntry()		check that user entered a valid
#								+/- integer value (+/- is optional)
#
# sets returnValue = 1 if true, sets intValue = 0 if false
##############################################################################

function isIntegerEntry()
{
    if [[ $1 =~ ^[\+-]?[[:digit:]]+$ ]]; then  
        returnValue=1
    else
        returnValue=0
    fi
}

####################################################################################################
# function isValidSize()		check that user entered a valid find file size
#								[+/-]n [b|c|k|M|G]
#								find does not allow a decimal point
# sets returnValue = 1 if true, sets returnValue = 0 if false
##############################################################################
function isValidSize()
{
	if [[ $1 =~ ^[\+-]?[[:digit:]]+[bckMG]?$ ]]; then
		returnValue=1
	else
		returnValue=0
	fi
}

##############################################################################
# function stripSignIfPositive()	    return the digits of the integer in
#                                       numberVariable without the + sign
##############################################################################
function stripSignIfPositive()
{
    declare tempValue=$1
    signValue=' '
    if [[ ${tempValue:0:1} == '+' ]]; then
        returnValue=${tempValue:1}
        signValue='+'
    elif [[ ${tempValue:0:1} == '-' ]]; then
        returnValue=${tempValue}
        signValue='-'
    else
        returnValue=$tempValue
   fi
}

##############################################################################
# function stripTrailingComma()	    returns the string without a trailing
#                                   comma in returnValue
##############################################################################
function stripTrailingComma()
{
    declare tempValue=$1
    declare -i lastCharIndex=${#tempValue}-1
    if [[ ${tempValue:$lastCharIndex} = ',' ]]; then
        returnValue=${tempValue:0:$lastCharIndex}
    else
        returnValue=$tempValue
    fi
}

##############################################################################
# function stripTrailingSlash()	returns the string without a trailing
#                                   '/' in returnValue
##############################################################################
function stripTrailingSlash()
{
    declare tempValue=$1
    declare -i lastCharIndex=${#tempValue}-1
    if [[ ${tempValue:$lastCharIndex} = '/' ]]; then
        returnValue=${tempValue:0:$lastCharIndex}
    else
        returnValue=$tempValue
    fi
}

##############################################################################
# function stripLeadingAndTrailingSpaces()		returns the string without 
#												leading or trailing spaces
#				                               	in returnValue
##############################################################################
function stripLeadingAndTrailingSpaces()
{
    declare tempValue=$1
    echo "beginning value = '$tempValue'"
    returnValue="$(echo -e "$tempValue" | sed -e 's/^[[:space:]]*//')"
    tempValue=$returnValue
    echo "after leading strip returnValue = '$returnValue'"
    returnValue="$(echo -e "$tempValue" | sed -e 's/[[:space:]]*$//')"

    #returnValue=${tempValue## }     # remove leading spaces
    #returnValue=${tempValue%% }     # remove trailing spaces
    echo "after trailing strip returnValue = '$returnValue'"
 }

##############################################################################
# function isValidPermission()      verify format for find -perm clause
#									! must be escaped (\!)
#									use \!-a=w to elicit ! - perm -a=w
##############################################################################
function isValidPermission()
{
    stripSignIfPositive $1
    if [[ $returnValue =~ ^-?/?[0-7]+$ ]]; then     # is it an integer?
        :   # integer permission
    elif [[ $returnValue =~ ^-?/?([augo][/+-=]([rwxst]{1,3}){1,3},?){1,3}$ ]]; then  
        :   # symbol permission
    else
		returnValue=''
	fi
    stripTrailingComma $returnValue
}

##############################################################################

I=34
isIntegerEntry $I
if [[ $returnValue -eq 1 ]]; then
    echo $I
else
    echo "NAN"
fi

I=35
isIntegerEntry $I
if [[ $returnValue -eq 1 ]]; then
    echo $I
else
    echo "NAN"
fi

I='borsht' 
isIntegerEntry $I
if [[ $returnValue -eq 1 ]]; then
    echo $I
else
    echo "NAN"
fi

I=37
isIntegerEntry $I
if [[ $returnValue -eq 1 ]]; then
    echo $I
else
    echo "NAN"
fi

I='AQ'
isIntegerEntry $I
if [[ $returnValue -eq 1 ]]; then 
    echo $I
else
    echo "NAN"
fi

echo
permission="-644"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="+777"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="755"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="+/644"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="-/u+w"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="u+w"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="u+r,g+r,o+r"
echo "raw permission: $permission"
isValidPermission $permission
echo "permission = $returnValue"
echo

permission="u+w,g+w,o+w,"
echo "raw permission: $permission"
isValidPermission $permission
if [[ ! -z $returnValue ]]; then
    permission="-perm $returnValue"
    echo $permission
else
    echo "ERROR Illegel permission: $1"
fi
echo

permission="u+rwx"
echo "raw permission: $permission"
isValidPermission $permission
if [[ ! -z $returnValue ]]; then
    permission="-perm $returnValue"
    echo $permission
else
    echo "ERROR Illegel permission: $1"
fi
echo

nopermission="/a+rwx"
echo "raw permission: $nopermission"
isValidPermission $nopermission
if [[ ! -z $returnValue ]]; then
	permission="! -perm $returnValue"
else
    echo "ERROR Illegel permission: $1"
fi
echo "permission: $permission"
echo

size=42k
isValidSize $size
echo "isValidSize returns $returnValue"
echo

size=4.7k
isValidSize $size
echo "isValidSize returns $returnValue"
echo

fileName='findgrep'
dirName='    /usr/bin/    '
if [[ ! -e $fileName ]]; then
    stripLeadingAndTrailingSpaces "$dirName"
    echo "dirName after strip: '$returnValue'"
    stripTrailingSlash $returnValue
    echo "dirName after strip: '$returnValue'"
    if [[ ! -e $returnValue/$fileName ]]; then
        echo "ERROR: Illegal linkTo name: $returnValue/$fileName"
    else
        echo "$returnValue/$fileName exists"
    fi
else
    echo "$fileName exists"
fi

echo
dirName='   class StrStrmBuf  '
echo "dirName before strip: '$dirName'"
stripLeadingAndTrailingSpaces "$dirName"
echo "dirName after strip: '$returnValue'"
echo

echo "The End"
exit 0