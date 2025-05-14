echo "Downloading dataset..."
cd yolov5/dataset
read -p "Enter the URL of the dataset zip file: " dataset_url
curl -L "$dataset_url" > roboflow.zip; unzip roboflow.zip; rm roboflow.zip
echo "Dataset downloaded and unzipped successfully"
echo "_________________________________________________________________________________________"
echo "changing train, val, test directories to function directory"
YAML_FILE="data.yaml"
if [ -f "$YAML_FILE" ]; then
    sed -i 's|train: ../train/images|train: ../dataset/train/images|' "$YAML_FILE"
    sed -i 's|val: ../valid/images|val: ../dataset/valid/images|' "$YAML_FILE"
    sed -i 's|test: ../test/images|test: ../dataset/test/images|' "$YAML_FILE"
else
    echo "YAML file not found!"
fi
echo "train, val, test directories changed successfully"
echo "_________________________________________________________________________________________"