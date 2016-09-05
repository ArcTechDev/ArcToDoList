# ArcToDoList

Overview:
ArcToDoList is an app allow you to manage your to do list. Idea of app was designed to focus on gesture interaction. You can categorize bunch of your tasks, add new task under certain category, as well as, sort your task order by moving them up/down or put a task into certain day. In task you can attach image, make a note or setup a notification.

Note:
Unfortunatelly, project was cancelled on the half way, therefore some of features are not implemented.

Gestures focus:
As app is organized task using table view and focus on gestures, therefore, I was researching for a third party UITableView which can have submenu under each task, in addition, to be interacted with different gestures such pan left/right, long press, double tap, long press move, tap and pull down, furthermore, gestures need to be extended or add new different kind of gesture.

Due to different of gestures requirmenet in design and I was not able to find ont for this particular requirement, I start to create one from scratch. Here is the github of the table view I created https://github.com/tomneo2004/SubTableView.git



To run project:
PS:This project is already included required third party library as well as cocoapod, if you don't want to update project's pod you can just open "ArcToDoList.xcworkspace" in project directory.

1. open terminal
2. cd to project directory
3. type pod init
4. type pod install
5. open project with ArcToDoList.xcworkspace
6. locate Podfile open it and insert following

target 'ArcToDoList' do

pod 'GoogleSignIn'
pod 'Facebook-iOS-SDK'
pod 'MagicalRecord'
pod 'GPUImage'
pod 'Firebase'
pod 'Firebase/Core'
pod 'Firebase/AppIndexing'
pod 'Firebase/Auth'
pod 'Firebase/Crash'
pod 'Firebase/Database'
pod 'Firebase/DynamicLinks'
pod 'Firebase/Messaging'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Storage'

end

target 'ArcToDoListTests' do

end

7. close project and back to terminal at same directory type pod install
8. open project ArcToDoList.xcworkspace