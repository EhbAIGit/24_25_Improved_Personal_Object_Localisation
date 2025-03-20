# 24_25_Improved_Personal_Object_Localisation
CLI

to train a box model use this command: 
python3 train.py --data dataset/data.yaml --cfg yolov5s.yaml --weights '' --batch-size 8

to train a segment model use this command: 
python3 segment/train.py --data data.yaml --weights yolov5s-seg.pt --img 640 --batch-size 8

test2ssfsefsfs