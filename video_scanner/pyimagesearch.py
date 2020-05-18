# 接下来要编写一个4点定位一张图片的工具

import numpy as np
import cv2

# 这个首要问题是，这个pts是个什么玩意
# This function takes a single argument, pts , which is a list of four points
# specifying the (x, y) coordinates of each point of the rectangle.

def order_points(pts):
    # 在这一步初始化一个容器，以“左上” “右上” “右下” “左下” 也就是顺时针顺序来记录点的坐标
    rect = np.zeros((4, 2), dtype="float32")

    # 故意设置 左上的点有最小值（从pts中提出的axis 1 上的和中的最小值 就是 x+y）， 右下的点有最大值
    s = pts.sum(axis=1)
    rect[0] = pts[np.argmin(s)]
    rect[2] = pts[np.argmax(s)]

    # 在计算了pts中的axis 1 上的各值之间的差后，右上的点储存最小的差值（就是每组x-y），左下储存最大的差值
    diff = np.diff(pts, axis=1)
    rect[1] = pts[np.argmin(diff)]
    rect[3] = pts[np.argmax(diff)]

    # 如是做，则可以返回一组被排好序的坐标，总之因为排好一定顺序的坐标是非常重要的，下面的函数就会指出这点
    return rect

def four_point_transform(image, pts):

    rect = order_points(pts)
    (tl, tr, br, bl) = rect

    # 在这里算出新得到的image的宽，就挑最大的宽度
    widthA = np.sqrt((bl[0] - br[0]) ** 2 + (bl[1] - br[1]) ** 2)
    widthB = np.sqrt((tl[0] - tr[0]) ** 2 + (tl[1] - tr[1]) ** 2)
    maxWidth = max(int(widthA), int(widthB))

    # 按照相同的原则算出新得到的image的长
    heightA = np.sqrt((bl[0] - tl[0]) ** 2 + (bl[1] - tl[1]) ** 2)
    heightB = np.sqrt((br[0] - tr[0]) ** 2 + (br[1] - tr[1]) ** 2)
    maxHeight = max(int(heightA), int(heightB))


    # 在得到新图像的尺寸之后储存在max们中后，利用他们去得到新图像的四角坐标，也是按照从左上开始顺时针方向
    dst = np.array([
        [0, 0],
        [maxWidth-1, 0],
        [maxWidth - 1, maxHeight - 1],
        [0, maxHeight - 1]
    ], dtype="float32")

    # 最后利用cv中的函数，先算出将原图经过透视变换后变成从正上方的俯瞰图所需的Transform Matrix M
    M = cv2.getPerspectiveTransform(rect, dst)
    # 再利用warpPerspective函数去得到最后的原图换成俯瞰图的成像
    warped = cv2.warpPerspective(image, M, (maxWidth, maxHeight)) # 这个应该是指定了最后进行了俯瞰化后的image应该有多大

    return warped

