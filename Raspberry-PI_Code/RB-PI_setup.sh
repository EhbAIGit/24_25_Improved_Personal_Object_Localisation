read -p "Enter the name of the project: " project_name
DEMO_DIR=$HOME/edgetpu/$project_name
mkdir -p $DEMO_DIR
echo "Installing dependencies..."
echo "_____________________________"
wget https://github.com/google-coral/test_data/raw/master/mobilenet_v1_1.0_224_l2norm_quant_edgetpu.tflite  -P $DEMO_DIR
wget https://dl.google.com/coral/sample_data/imprinting_data_script.tar.gz  -P $DEMO_DIR
tar zxf $DEMO_DIR/imprinting_data_script.tar.gz -C $DEMO_DIR
bash $DEMO_DIR/imprinting_data_script/download_imprinting_test_data.sh $DEMO_DIR
echo "Installing pycoral..."
echo "_____________________________"
mkdir coral && cd coral
git clone https://github.com/google-coral/pycoral.git
cd pycoral/examples/
echo "___________________________"
echo "downloading webcam script..."
cat << 'EOF' > $DEMO_DIR/webcam_detect.py
import cv2
import time
from pycoral.adapters import common, detect
from pycoral.utils.dataset import read_label_file
from pycoral.utils.edgetpu import make_interpreter
import os

# Dynamically set base path
base_path = os.path.dirname(os.path.realpath(__file__))
model_path = os.path.join(base_path, 'model_edgetpu.tflite')
label_path = os.path.join(base_path, 'labels.txt')

# Load model and labels
interpreter = make_interpreter(model_path)
interpreter.allocate_tensors()
labels = read_label_file(label_path)
input_size = common.input_size(interpreter)

# Open webcam
cap = cv2.VideoCapture(0)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Resize and convert
    image = cv2.resize(frame, input_size)
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    common.set_input(interpreter, rgb)

    # Run inference
    start = time.time()
    interpreter.invoke()
    inference_time = (time.time() - start) * 1000

    # Get detections
    objs = detect.get_objects(interpreter, score_threshold=0.4)
    
    for obj in objs:
        bbox = obj.bbox
        label = labels.get(obj.id, obj.id)
        cv2.rectangle(frame, (bbox.xmin, bbox.ymin), (bbox.xmax, bbox.ymax), (0, 255, 0), 2)
        cv2.putText(frame, f"{label}: {obj.score:.2f}", (bbox.xmin, bbox.ymin - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 2)

    # Show info
    cv2.putText(frame, f"Inference: {inference_time:.1f}ms", (10, 20),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)

    # Display frame
    cv2.imshow("EdgeTPU Detection", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
EOF

chmod +x $DEMO_DIR/webcam_detect.py

echo "Python webcam detection script placed in $DEMO_DIR"
echo "Download complete!"