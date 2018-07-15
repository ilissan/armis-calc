#!/usr/bin/env bash

echo 'The following Maven command installs your Maven-built Java application'
echo 'into the local Maven repository, which will ultimately be stored in'
echo 'Jenkins''s local Maven repository (and the "maven-repository" Docker data'
echo 'volume).'
set -x
mvn jar:jar install:install help:evaluate -Dexpression=project.name
set +x

echo 'The following complex command extracts the value of the <name/> element'
echo 'within <project/> of your Java/Maven project''s "pom.xml" file.'
set -x
NAME=`mvn help:evaluate -Dexpression=project.name | grep "^[^\[]"`
set +x

echo 'The following complex command behaves similarly to the previous one but'
echo 'extracts the value of the <version/> element within <project/> instead.'
set -x
VERSION=`mvn help:evaluate -Dexpression=project.version | grep "^[^\[]"`
set +x

echo 'The following command runs and outputs the execution of your Java'
echo 'application (which Jenkins built using Maven) to the Jenkins UI.'
set -x
expected_result='(i=37,j=1,x=6,y=35)'
IFS=$','
read -a sorted_arr_exp_rslt <<< "$(echo $expected_result | sed 's/[()]//g')"
# get actual result
tmp_actual_result=$(java -jar target/${NAME}-${VERSION}.jar <<-EOF
i=0
j=++i
x=i+++5
y=5+3*10
i+=y
EOF
)
# remove redundant strings from output
actual_result=$(echo $tmp_actual_result | sed 's/.*\.//')
# convert result into arr and sort
read -a arr_actual_result <<< "$(echo $actual_result | sed 's/[()]//g')"
sorted_arr_act_rslt=("$(sort <<<"${arr_actual_result[*]}")")
unset IFS
# show arrays
echo '=============expected=============='
printf '%s\n' "${sorted_arr_exp_rslt[@]}"
echo '=============actual================'
printf '%s\n' "${sorted_arr_act_rslt[@]}"
echo '==================================='
# compare results
[ ${#sorted_arr_exp_rslt[*]} != ${#sorted_arr_act_rslt[*]} ] && { echo arrays different size; exit 1; }
for ii in ${!sorted_arr_exp_rslt[*]}; do
    [ "${sorted_arr_exp_rslt[$ii]}" == "${sorted_arr_act_rslt[$ii]}" ] || { echo different element $ii; exit 1; }
done
echo arrays identical
exit 0