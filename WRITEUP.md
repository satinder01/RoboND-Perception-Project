## Project: Perception Pick & Place
---
## [Rubric](https://review.udacity.com/#!/rubrics/1067/view) Points
![demo-2](https://user-images.githubusercontent.com/20687560/28748286-9f65680e-7468-11e7-83dc-f1a32380b89c.png)

[//]: # (Image References)

[screenshot_world_1]:./misc/tabletop1.png
[screenshot_world_2]:./misc/tabletop2.png
[screenshot_world_3]:./misc/tabletop3.png
[normalized_confusion_matrix]:./misc/confusion_matrix_with_normalization.png


### Here I will consider the rubric points individually and describe how I addressed each point in my implementation.  

---
### Writeup / README

#### 1. Provide a Writeup / README that includes all the rubric points and how you addressed each one.  You can submit your writeup as markdown or pdf.  

You're reading it!

### Exercise 1, 2 and 3 pipeline implemented
#### 1. Complete Exercise 1 steps. Pipeline for filtering and RANSAC plane fitting implemented.

Image recognition pipeline:

1. Convert ROS msg to PCL data
2. Voxel Grid Downsampling with leaf_size=0.005 to reduce memory consumption and processing time.
3. A passthrough filter to define the region of interest. The ROI is `` 0.3 < z < 5.0 `` and ``0.34 < x < 1 ``
4. Statistical outline filter with ``thr = mean_distance + x * std_dev`` adjusted k-mean to 50 and scale factor of 0.5 for removing noise.
5. RANSAC plane segmentation in order to separate the table from the objects on it. A maximum threshold of 0.015 worked well to fit the geometric plane model. The cloud is then segmented in two parts the table (inliers) and the objects of interest (outliers). The segments are published to ROS as ``/pcl_table`` and ``/pcl_objects``. From this point onwards the objects segment of the point cloud is used for further processing.


#### 2. Complete Exercise 2 steps: Pipeline including clustering for segmentation implemented.  
The point cloud needs to be clustered to detect individual object.

Following parameters worked for Euclidean clustering. Cluster tolerance of 0.01, min cluster 50 and max cluster 15000

The clusters are colored for visualization in RViz, the corresponding ROS subject is ``/pcl_cluster``.

#### 2. Complete Exercise 3 Steps.  Features extracted and SVM trained.  Object recognition implemented.
Here is an example of how to include an image in your writeup.

![demo-1](https://user-images.githubusercontent.com/20687560/28748231-46b5b912-7467-11e7-8778-3095172b7b19.png)

To generate the training sets, I added the items from all the pick_list yaml files and then uniquified them to get one complete list 


```
https://github.com/satinder01/RoboND-Perception-Project/blob/master/pr2_robot/scripts/capture_features.py
models = ['biscuits', 'book', 'eraser', 'glue', 'snacks', 'soap', 'soap2', 'sticky_notes']
```


Features were extracted as color histogram. Tried using RGB color space and found the results to be very poor.
Finally settled down for HSV
10 poses per object
```
https://github.com/satinder01/RoboND-Perception-Project/blob/master/pr2_robot/scripts/features.py
nbins = 32
bins_range = (0,256)
```

The accuracy achieved by doing this was

```
Features in Training Set: 80
Invalid Features in Training set: 0
Scores: [ 0.6875  0.875   0.8125  0.8125  0.9375]
Accuracy: 0.82 (+/- 0.17)
accuracy score: 0.825
```

![normalized confusion matrix][normalized_confusion_matrix] 


### Pick and Place Setup

#### 1. For all three tabletop setups (`test*.world`), perform object recognition, then read in respective pick list (`pick_list_*.yaml`). Next construct the messages that would comprise a valid `PickPlace` request output them to `.yaml` format.


###### Scene 1
See the file [output_1.yaml](https://github.com/satinder01/RoboND-Perception-Project/blob/master/pr2_robot/output/output_1.yaml) and the screenshot below.

![Recognized objects for scene 1.][screenshot_world_1]

###### Scene 2
See the file [output_2.yaml](https://github.com/satinder01/RoboND-Perception-Project/blob/master/pr2_robot/output/output_2.yaml) and the screenshot below.

![Recognized objects for scene 2.][screenshot_world_2]

###### Scene 3
See the file [output_3.yaml](https://github.com/satinder01/RoboND-Perception-Project/blob/master/pr2_robot/output/output_3.yaml) and the screenshot below.

![Recognized objects for scene 3.][screenshot_world_3]



### Improvement
* The 'book' was not identified correctly so need to work more on that to find out whether increases more poses will help or need to investigate if we need to work with extracting features other than HSV colorspace

* The pr2 robot was missing lifting objects most of the time. And sometime it dropped the objects when it was able to pick. Need to investigate how to make pick and place work effectively.
