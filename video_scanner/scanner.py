from pyimagesearch import four_point_transform # 别看有红线，但是是可以通过编译的
from skimage.filters import threshold_local
import numpy as np
import argparse
import cv2
import imutils

if False:
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--image", required=True, help="Path to the image to be scanned")
    args = vars(ap.parse_args())
    image = cv2.imread(args["image"])
else:
    image = cv2.imread("file.jpg")
    # cv2.imshow("original image", image)
    # cv2.waitKey(0)


print(image.shape)
ratio = image.shape[0] / 500.0 # 读取了图片的宽
orig = image.copy()
image = imutils.resize(image, height=500)
#cv2.imshow("resize image", image)
#cv2.waitKey(0)

# 换成灰度图，高斯模糊一波去除高频噪声，然后detect edge
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
gray = cv2.GaussianBlur(gray, (5, 5), 1)
edged = cv2.Canny(gray, 20, 400)

# 展示出处理好的原图跟其边界检测图
print("[INFO] STEP 1: Edge Detection")
cv2.imshow("Original Image", image)
cv2.imshow("Edge Detection", edged)
cv2.waitKey(0)
cv2.destroyAllWindows()


# 下面开始找到这个需要检测的物件的轮廓

cnts = cv2.findContours(edged.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
cnts = imutils.grab_contours(cnts)
cnts = sorted(cnts, key=cv2.contourArea, reverse=True)[:5]
#screenCnt = np.array([])

# 来一个个对比我们找到的image上的所有轮廓
for c in cnts:
    # 先拟合出轮廓
    peri = cv2.arcLength(c, True)
    approx = cv2.approxPolyDP(c, 0.02 * peri, True)
    print("object detected")
    print(approx)
    print(approx.shape)


    # 如果说拟合出的这个轮廓刚好有4点，那么就说我们找到了我们的目标screen
    if len(approx) == 4:
        screenCnt = approx
        print(approx)
        print(approx.shape)
        break


# 发生了很有趣的现象，我使用的都是同一种参数方法，但是，若原图保持竖直，则可以成功检测出轮廓，若原图横过来，怎么做都不能成功
print("[INFO] STEP 2: Find contours of paper")
cv2.drawContours(image, [screenCnt], -1, (0, 0, 255), 2)
cv2.imshow("Outline", image)
cv2.waitKey(0)
cv2.destroyAllWindows()


# 在这里开始使用将图片转变为俯瞰模式的算法
warped = four_point_transform(orig, screenCnt.reshape(4, 2) * ratio)

# 再将新图片转成灰度图进行 滤波操作 来给他加上 black and white paper effect
warped = cv2.cvtColor(warped, cv2.COLOR_BGR2GRAY)
T = threshold_local(warped, 11, offset=10, method="gaussian")
warped = (warped > T).astype("uint8") * 255

print("[INFO] STEP 3: Apply perspective transformation")
cv2.imshow("Original", imutils.resize(orig, height=650))
cv2.imshow("Scanned", imutils.resize(warped, height=650))
cv2.waitKey(0)
cv2.imwrite("file_scan.jpg", imutils.resize(warped, height=650))