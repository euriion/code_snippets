#!/bin/bash
# A utliity script to build drake

if [[ -z "$1" ]]; then
  echo "Usage: $0 base-dir-to-install-drake"
  echo "exam: $0 /home/bigdata/drake"
  exit 1
fi

start_dir=`pwd`
drake_basedir="$1"

if [[ -e "$drake_basedir" ]]; then
  echo "$drake_basedir already exists"
else
  mkdir $drake_basedir
  rc=$?
  if [[ $rc != 0 ]]; then
    echo "failure to make the directory '$drake_basedir'"
    exit $rc
  fi
fi

cd $drake_basedir
git clone https://github.com/Factual/drake.git drake_source

if [[ -e ./lein ]]; then
  rm ./lein
fi

wget https://raw.github.com/technomancy/leiningen/stable/bin/lein

chmod +x ./lein
cd drake_source
../lein uberjar
cd ..

echo "#!/bin/bash
DRAKE_JAR_PATH=\"$drake_basedir/drake_source/target\"
java -cp $drake_basedir/drake_source/target/drake.jar drake.core \$@" > ./drake

chmod +x drake
path_dir=$(pwd)

cd $start_dir

echo "done!"
echo "add path the '$path_dir' in to your PATH environment variable"
echo "PATH=\$PATH:$path_dir"
