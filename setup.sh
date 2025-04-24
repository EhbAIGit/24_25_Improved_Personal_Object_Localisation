echo "Cloning the yolov5 repo from github"
git clone https://github.com/ultralytics/yolov5
cd yolov5
pip install -r requirements.txt
echo "Yolov5 repo cloned successfully"
echo "_________________________________________________________________________________________"
echo "Downloading Custom Dataset"
mkdir dataset && cd dataset

