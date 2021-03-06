#!/bin/bash

if [ $# -le 2 ] 
then
    echo "Usage: " $0 " <actual-en> <translated-en> <non-en-lang>";
    exit 1;
fi

actualEn=$1
translEn=$2
nonEnLang=$3
count=0

mkdir -p /tmp/compare-en-es/reference
mkdir -p /tmp/compare-en-es/system
mkdir -p /home/dwaipayan/$nonEnLang

exec 3<$actualEn
exec 4<$translEn
while IFS= read -r actualEnArticle <&3
      IFS= read -r translEnArticle <&4
do
    # echo $actualEnArticle
    # echo $translEnArticle
    # sleep 1
    echo $count

    echo "Comparing file - $compareFile"
    echo $actualEnArticle > /tmp/compare-en-es/reference/es_actualEn.txt
    echo $translEnArticle > /tmp/compare-en-es/system/es_translEn.txt
    count=`expr $count + 1`

    prop_name="rouge.properties"
    cat > $prop_name << EOL
#==Project Directory==
#root directory for system and reference summaries
project.dir=/tmp/compare-en-es/

#==ROUGE-TYPE==
#topic, topicUniq, normal
#don't change this if you are not sure what this does
rouge.type=normal

#what type rouge-metric to use? 
#options:1,2,3,..N; S1,S2,S3...SN; SU1, SU2, SU3...SUN; L
#you can specify multiple rouge metrics just use comma for separation
ngram=L,1,2,SU4

# this is to compute F-score
# setting beta to 1 makes this equivalent to the harmonic mean between precision and recall
# use a large beta value to give more weight to recall (Document Understanding Conference used a large DUC value for eval)
# setting a beta value < 1 gives preference to precision. Use 0.5 if you want to give more weights to precision.
beta=1

#==STOP WORDS==

#remove stop words?
stopwords.use=true

#location of stop words file (can change based on language)
stopwords.file=resources/stopwords-rouge-default.txt

#==TOPIC SETTINGS==
#only set this if topic or topicUniq are used	
topic.type=nn|jj
	
#==SYNONYM SETTINGS==

#use synonyms?
synonyms.use=false

#requires WordNet installation
synonyms.dir=default	


#==POS Tagging Settings (needed for topic and synonyms)==
pos_tagger_name=english-bidirectional-distsim.tagger

#====STEMMER SETTINGS===
stemmer.name=englishStemmer

#use stemming?
stemmer.use=false

#==Output Settings==
#options:file,console
#the file option prints to screen and generates CSV output file
output=file
outputFile=/home/dwaipayan/$nonEnLang/$count.tsv
EOL
    # .properties file created  
    echo $count

    java -cp rouge2-1.2.1.jar com.rxnlp.tools.rouge.ROUGECalculator -Drouge.prop=$prop_name
done
