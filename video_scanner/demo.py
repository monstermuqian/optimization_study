from imutils.video import VideoStream
import time
import cv2
import imutils
from pyimagesearch import four_point_transform
from skimage.filters import threshold_local
import numpy as np


vs = VideoStream(str=0).start()
time.sleep(2.0)

while True:
    frame = vs.read()
    frame = imutils.resize(frame, width=800)
    #print(frame.shape)

    cv2.imshow("Test Video", frame)
    key = cv2.waitKey(1) & 0xFF
    if key == ord("q"):
        break
    elif key == ord("l"):
        image = frame
        #cv2.imshow('test_screen shot', frame)
        ratio = image.shape[0] / 500.0
        orig = image.copy()
        image = imutils.resize(image, height=500)

        # 将原图换成灰度图，高斯模糊去掉高频噪声，最后用canny算法找出所有edge
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (5, 5), 0.4)
        cv2.imshow("gray", gray)
        cv2.waitKey(0)
        edged = cv2.Canny(gray, 50, 125)
        cv2.imshow("edged", edged)
        cv2.waitKey(0)

        # 开始寻找这个物体的轮廓
        cnts = cv2.findContours(edged.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
        cnts = imutils.grab_contours(cnts)
        cnts = sorted(cnts, key=cv2.contourArea, reverse=True)[:5]

        # 来一个个对比我们在image上定位出的所有轮廓
        for c in cnts:
            epsilon = 0.02*cv2.arcLength(c, True)
            approx = cv2.approxPolyDP(c, epsilon, True)
            print(approx)
            print(approx.shape)

            if len(approx) == 4:
                screenCnt = approx
                print(approx)
                break

        # 最终得到的检测出来的矩形边界的四点坐标被储存在screenCnt中
        # 在这里将图片转换成四点检测模式的基础
        cv2.drawContours(image, [screenCnt], -1, (0, 0, 255), 2)
        cv2.imshow("Outline", image)
        cv2.waitKey(0)



        warped = four_point_transform(orig, screenCnt.reshape(4, 2) * ratio)
        warped = cv2.cvtColor(warped, cv2.COLOR_BGR2GRAY)
        T = threshold_local(warped, 25, offset=10, method="gaussian")
        warped = (warped > T).astype("uint8") * 255


        cv2.imshow("Scanned", imutils.resize(warped, height=300))
        cv2.waitKey(0)







cv2.destroyAllWindows()
vs.stop()