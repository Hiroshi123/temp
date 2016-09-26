

from pylab import *
from sklearn import datasets
from sklearn.svm import SVC
import json
from numpy import *
import cv2
from sklearn.cross_validation import train_test_split
from sklearn.cross_validation import cross_val_score, KFold
from scipy.stats import sem
from sklearn import metrics
from matplotlib.patches import Rectangle
from scipy.ndimage import zoom


class SVM():

    def __init__(self):
        pass
    
    
    def main(self):
        
        X_train,X_test,y_train,y_test = self.modelSet()
        
        self.evaluate_cross_validation(X_train, y_train, 5)
        self.train_and_evaluate(X_train, X_test, y_train, y_test)
        
        
    def modelSet(self):
        faces = datasets.fetch_olivetti_faces()
        self.clf = SVC(kernel='linear')
        #trainer = Trainer()
        
        results = json.load(open('data/results.xml'))

        indices = [i for i in results]
        data = faces.data[indices, :]

        target = [results[i] for i in results]
        target = array(target).astype(int32)
        
        #self.X_train, self.X_test, self.y_train, self.y_test
        
        return train_test_split(
            data, target, test_size=0.25, random_state=0)
    
    
    def evaluate_cross_validation(self, X, y, K):
        # create a k-fold cross validation iterator
        cv = KFold(len(y), K, shuffle=True, random_state=0)
        # by default the score used is the one returned by score method of the estimator (accuracy)
        scores = cross_val_score(self.clf, X, y, cv=cv)
        print (scores)
        print ("Mean score: {0:.3f} (+/-{1:.3f})".format(
            mean(scores), sem(scores)))
        
    def train_and_evaluate(self, X_train, X_test, y_train, y_test):
        
        self.clf.fit(X_train, y_train)
        
        print ("Accuracy on training set:")
        print (self.clf.score(X_train, y_train))
        print ("Accuracy on testing set:")
        print (self.clf.score(X_test, y_test))

        y_pred = self.clf.predict(X_test)

        print ("Classification Report:")
        print (metrics.classification_report(y_test, y_pred))
        print ("Confusion Matrix:")
        print (metrics.confusion_matrix(y_test, y_pred))

        

class Camera():

    def __init__(self,clf):
        self.clf = clf
        pass
    
    
    def detect_face(self,frame):
        
        cascPath = "data/haarcascade_frontalface_default.xml"
        faceCascade = cv2.CascadeClassifier(cascPath)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        detected_faces = faceCascade.detectMultiScale(
            gray,
            scaleFactor=1.1,
            minNeighbors=6,
            minSize=(100, 100),
            flags=cv2.cv.CV_HAAR_SCALE_IMAGE
        )
        return gray, detected_faces
    
    
    def extract_face_features(self,gray, detected_face, offset_coefficients):
        
        (x, y, w, h) = detected_face
        horizontal_offset = offset_coefficients[0] * w
        vertical_offset = offset_coefficients[1] * h
        extracted_face = gray[y+vertical_offset:y+h,
                              x+horizontal_offset:x-horizontal_offset+w]
        new_extracted_face = zoom(extracted_face, (64. / extracted_face.shape[0],
                                           64. / extracted_face.shape[1]))
        new_extracted_face = new_extracted_face.astype(float32)
        new_extracted_face /= float(new_extracted_face.max())

        return new_extracted_face

    def predict_face_is_smiling(self,extracted_face):
        
        return self.clf.predict(extracted_face.ravel())
    
    
    def main_loop(self):
        video_capture = cv2.VideoCapture(0)
        while True:
            # Capture frame-by-frame
            ret, frame = video_capture.read()
            # detect faces
            gray, detected_faces = self.detect_face(frame)

            face_index = 0

            # predict output
            for face in detected_faces:
                (x, y, w, h) = face
                if w > 100:
                    # draw rectangle around face
                    cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)
                    
                    # extract features
                    extracted_face = self.extract_face_features(gray, face, (0.03, 0.05)) #(0.075, 0.05)
                    
                    # predict smile
                    prediction_result = self.predict_face_is_smiling(extracted_face)
                    
                    # draw extracted face in the top right corner
                    frame[face_index * 64: (face_index + 1) * 64, -65:-1, :] = cv2.cvtColor(extracted_face * 255, cv2.COLOR_GRAY2RGB)
                    
                    # annotate main image with a label
                    if prediction_result == 1:
                        cv2.putText(frame, "SMILING :)",(x,y), cv2.FONT_HERSHEY_SIMPLEX, 2, 155, 10)
                    else:
                        cv2.putText(frame, "not smiling :(",(x,y), cv2.FONT_HERSHEY_SIMPLEX, 2, 155, 10)
                        
                    # increment counter
                    face_index += 1
                    
            # Display the resulting frame
            cv2.imshow('Video', frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            
        # When everything is done, release the capture
        video_capture.release()
        cv2.destroyAllWindows()
        
        
if __name__ == "__main__":
    
    #evaluate_cross_validation(clf, X_train, y_train, 5)
    #train_and_evaluate(clf, X_train, X_test, y_train, y_test)
    
    svm = SVM()
    svm.main()
    
    camera = Camera(svm.clf)
    camera.main_loop()
    
    
