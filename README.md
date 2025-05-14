# Improved Personal Object Localisation

This repository provides tools for training object detection and segmentation models using YOLOv5.

---
## **yolov5 model object detection on PC**

### **Setup**
open a terminal and run the following command
```bash
bash setup.sh
```

### **Ceating a dataset**
To create a good dataset i would higly recomend using this guide
https://www.ejtech.io/learn/eight-labeling-tips

### **Train an Object Detection Model**

#### **Make sure your dataset is using the yolov5 pytorch format**
To Train an Object Detection Model navigate to the dataset dir and in the terminal paste the download code for your dataset using roboflow.


(make sure to change the path of your train, valid and test paths to the correct path)

if you are using roboflow use the add_RF_dataset bash file for a easy and fast setup
```bash
bash add_RF_dataset.sh
```

Then run the following command.
```bash
python3 train.py --data dataset/data.yaml --cfg yolov5s.yaml --weights '' --batch-size 8
```

### **Running an Object Detection Model**
To run an object detection use the following command.
```bash
python3 detect.py --weights path/to/your/weights --source 0  --img 640
```

example:
```bash
python3 detect.py --weights runs/train/exp6/weights/best.pt --source 0  --img 640
```
(this will use the webcam for the detection)

## **Raspberry PI object detection using Google Coral TPU**

### **Setup**

the full official tutorial from coral is here if you wish to learn more: https://coral.ai/docs/edgetpu/retrain-classification-ondevice/#retrain-a-model-on-device-with-our-sample
