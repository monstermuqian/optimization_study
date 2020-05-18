from imutils.video import VideoStream
import numpy as np
import imutils
import time
import cv2


print("[INFO] Loading the model.....")
net = cv2.dnn.readNetFromCaffe("deploy.prototxt.txt", "res10_300x300_ssd_iter_140000.caffemodel")

print("[INFO] starting video stream...")

# 若要使用树莓派摄像头，则在这里进行改动，改动详情参考imutils库
vs = VideoStream(src=0).start()
time.sleep(2.0)


while True:

    frame = vs.read()
    frame = imutils.resize(frame, width=400)

    (h, w) = frame.shape[:2] # 取数据frame的shape的前两位，来表示高和宽
    blob = cv2.dnn.blobFromImage(cv2.resize(frame, (300, 300)), 1.0, (300, 300), (104.0, 177.0, 123.0))

    net.setInput(blob)
    detections = net.forward()
    print("[INFO] For validating the result from the net....")
    print("[INFO] the data type of it is :")
    print(type(detections))
    print("[INFO] the content of it is :")
    print(detections[0, 0, 0, 0:3])
    print("[INFO] the shape of it is :")
    print(detections.shape)
    # 到这里完全弄懂这个 detection 出来的结构是什么，真正储存可以解读的结果的地方在detection的第四维一共七个数字上
    # 前两位啥都不是，就单单是0跟1，第三位是置信概率，第四位到第七位是标定检测结构的矩形的对角两个顶点的，一共4个坐标值


    for i in range(0, detections.shape[2]) :
        confidence = detections[0, 0, i, 2]

        if confidence < 0.8:
            continue

        box = detections[0, 0, i, 3:7] * np.array([w, h, w, h])
        (startX, startY, endX, endY) = box.astype("int")
        cv2.rectangle(frame, (startX, startY), (endX, endY), (0, 255, 0), 2)

        y = startY - 10 if startY - 10 > 10 else startY + 10
        cv2.putText(frame, "{:.2f}%".format(confidence*100), (startX, y), cv2.FONT_HERSHEY_COMPLEX, 0.45,
                    (0, 0, 225), 2)



    cv2.imshow("Test of the result", frame)
    key = cv2.waitKey(1) & 0xFF
    if key == ord("q"):
        break


cv2.destroyAllWindows()
vs.stop()
