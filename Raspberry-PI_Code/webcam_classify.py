import cv2
import time
from pycoral.utils.dataset import read_label_file
from pycoral.adapters import classify
from pycoral.adapters import common
from pycoral.utils.edgetpu import make_interpreter
import os

# Set the base path to your project folder
base_path = '/home/pi/edgetpu/My_Project'

# Paths to the model and labels file
model_path = os.path.join(base_path, 'model_edgetpu.tflite')
label_path = os.path.join(base_path, 'labels.txt')

# Load model and labels
interpreter = make_interpreter(model_path)
interpreter.allocate_tensors()
labels = read_label_file(label_path)
input_size = common.input_size(interpreter)

# Open webcam (device 0)
cap = cv2.VideoCapture(0)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Resize frame to the model's expected input size
    resized_frame = cv2.resize(frame, input_size)
    
    # Convert to RGB format
    rgb_frame = cv2.cvtColor(resized_frame, cv2.COLOR_BGR2RGB)
    
    # Set the input tensor
    common.set_input(interpreter, rgb_frame)

    # Run inference
    start = time.time()
    interpreter.invoke()
    inference_time = (time.time() - start) * 1000

    # Get top result
    classes = classify.get_classes(interpreter, top_k=1)
    
    # Display result on original frame
    if classes:
        class_id = classes[0].id
        score = classes[0].score
        label = labels.get(class_id, class_id)
        cv2.putText(frame, f"{label} ({score:.2f}) - {inference_time:.1f}ms", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

    # Show frame
    cv2.imshow("Coral EdgeTPU Classification", frame)

    # Exit on 'q' key
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
