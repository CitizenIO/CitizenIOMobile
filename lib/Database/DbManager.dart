import 'dart:io';
import 'package:CitizenIO/Database/ReputationManager.dart';
import 'package:CitizenIO/Model/Task.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class DatabaseManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var uuid = Uuid();

  Future saveUserData(
    String username,
    String email,
    String phoneNumber,
  ) {
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');
    User currentUser = auth.currentUser;

    return usersRef
        .doc(currentUser.uid)
        .set({
          'UserName': username,
          'Email': email,
          'PhoneNumber': phoneNumber,
          'ProjectIds': [],
          'StarredProjectIds': [],
          'StarredProjectCount': 0,
          'VolunteeringProjectCount': 0,
          'VolunteeringProjectIds': [],
          'Reputation': 0,
          'Uid': currentUser.uid,
        })
        .then((value) => print("User data saved to Firestore"))
        .catchError((error) => print("Failed to add user data: $error"));
  }

  Future createProjectIdDoc() async {
    CollectionReference projectsRef = firestore.collection('Projects');
    await projectsRef.doc('ProjectIds').set({
      'ProjectIds': [],
    });
  }

  Future createProject(String uid) async {
    var projectId = uuid.v4();
    List projectIds = [];

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    await projectsRef
        .doc('ProjectIds')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (!documentSnapshot.exists) {
        createProjectIdDoc();
      }
    });

    await projectsRef.doc(projectId).set({
      'ReferenceImages': [],
      'DonationsAccepted': false,
      'Headline': '',
      'Description': '',
      'Leader': '',
      'City': '',
      'Prize': '',
      'AmountDonated': 0,
      'DonationGoal': 0,
      'Donators': {}, // {name: amountDonated}
      'NumberOfVolunteers': 0,
      'VolunteerGoal': 0,
      'Volunteers': [],
      'NumberOfStars': 0,
      'StartDate': null,
      'TimeLineItems': [],
      'Location': null,
      'ProjectId': projectId,
      'Uid': uid,
      'Verified': false,
      'Reports': [],
    });

    await usersRef.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        print('Document data: $data');
        projectIds = data['ProjectIds'];
        projectIds.add(projectId);
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'ProjectIds': projectIds})
        .then((value) => print("Updated ProjectIds"))
        .catchError((error) => print("Failed to update ProjectIds: $error"));

    await projectsRef
        .doc('ProjectIds')
        .update({'ProjectIds': projectIds})
        .then((value) => print("Updated ProjectIds in project ref"))
        .catchError((error) =>
            print("Failed to update ProjectIds in project ref: $error"));
  }

  Future updateLocation(GeoPoint location) async {
    var projectId;

    CollectionReference projectsRef = firestore.collection('Projects');

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        projectId = data['ProjectIds'].last;
        print("Project id is $projectId");
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Location': location})
        .then((value) => print("Updated Location"))
        .catchError((error) => print("Failed to update Location: $error"));
  }

  Future<List> getImageURL(File image, Timestamp folderName) async {
    String path = 'Images/${folderName.toDate().toString()}/Media.png';
    print("Uploading image in firebase storage");
    await firebase_storage.FirebaseStorage.instance.ref(path).putFile(image);
    print("Uploaded image in firebase storage");
    print("Downloading url of image");
    String url = await downloadUrl(path);
    print("Received url of image: $url");
    print("Uploading url to firestore");
    List urls = await uploadUrl(url);
    print("Received urls from firestore: $urls");
    return urls;
  }

  Future uploadProject(
    String headline,
    String description,
    String leader,
    String prize,
    Timestamp startDate,
    String city,
    bool donationsAccepted,
    int donationGoal,
    int volunteerGoal,
  ) async {
    var projectId;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        projectId = data['ProjectIds'].last;
        print("Project id is $projectId");
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Headline': headline})
        .then((value) => print("Updated Headline"))
        .catchError((error) => print("Failed to update Headline: $error"));
    projectsRef
        .doc(projectId)
        .update({'Description': description})
        .then((value) => print("Updated Description"))
        .catchError((error) => print("Failed to update Description: $error"));
    projectsRef
        .doc(projectId)
        .update({'Leader': leader})
        .then((value) => print("Updated Leader"))
        .catchError((error) => print("Failed to update Leader: $error"));
    projectsRef
        .doc(projectId)
        .update({'Prize': prize})
        .then((value) => print("Updated Prize"))
        .catchError((error) => print("Failed to update Prize: $error"));
    projectsRef
        .doc(projectId)
        .update({'StartDate': startDate})
        .then((value) => print("Updated StartDate"))
        .catchError((error) => print("Failed to update StartDate: $error"));
    projectsRef
        .doc(projectId)
        .update({'City': city})
        .then((value) => print("Updated City"))
        .catchError((error) => print("Failed to update City: $error"));
    projectsRef
        .doc(projectId)
        .update({'DonationsAccepted': donationsAccepted})
        .then((value) => print("Updated DonationsAccepted"))
        .catchError(
            (error) => print("Failed to update DonationsAccepted: $error"));
    projectsRef
        .doc(projectId)
        .update({'VolunteerGoal': volunteerGoal})
        .then(
            (value) => print("Updated MinVolunteerRequirement in projects_ref"))
        .catchError((error) => print(
            "Failed to update MinVolunteerRequirement in projects_ref: $error"));
    projectsRef
        .doc(projectId)
        .update({'DonationGoal': donationGoal})
        .then((value) => print("Updated DonationsAccepted in projects_ref"))
        .catchError((error) => print(
            "Failed to update DonationsAccepted in projects_ref: $error"));
    projectsRef
        .doc(projectId)
        .update({'ProjectId': projectId})
        .then((value) => print("Updated ProjectId in projects_ref"))
        .catchError((error) =>
            print("Failed to update ProjectId in projects_ref: $error"));
    projectsRef
        .doc(projectId)
        .update({'Uid': auth.currentUser.uid})
        .then((value) => print("Updated Uid in projects_ref"))
        .catchError(
            (error) => print("Failed to update Uid in projects_ref: $error"));
  }

  Future<String> downloadUrl(String path) async {
    return await firebase_storage.FirebaseStorage.instance
        .ref(path)
        .getDownloadURL();
  }

  Future<List> uploadUrl(String url) async {
    CollectionReference projectsRef = firestore.collection('Projects');

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    var projectId;
    List urls;

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        projectId = data['ProjectIds'].last;
        print("Project is $projectId");
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        urls = data['ReferenceImages'];
        urls.add(url);
        print("Urls are $urls");
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .update({'ReferenceImages': urls})
        .then((value) => print("Updated ReferenceImages"))
        .catchError(
            (error) => print("Failed to update ReferenceImages: $error"));

    return urls;
  }

  Future<bool> isStarred(var projectId) async {
    List starredProjectIds;
    bool isStarred = false;
    print('Input project ID is $projectId');
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        starredProjectIds = data['StarredProjectIds'];
        starredProjectIds.forEach((starredProjectId) {
          if (starredProjectId == projectId) {
            print("Returnung true");
            isStarred = true;
          }
        });
      } else {
        print('Document does not exist on the database');
      }
    });
    print("Is started is equals to $isStarred");
    return isStarred;
  }

  Future star(var projectId) async {
    List starredProjectIds;
    int starredProjectCount;
    int numberOfStarsProject;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    print("Starring project: id is $projectId");

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        starredProjectIds = data['StarredProjectIds'];
        starredProjectIds.add(projectId);
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        starredProjectCount = data['StarredProjectCount'];
        starredProjectCount = starredProjectCount + 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        numberOfStarsProject = data['NumberOfStars'];
        numberOfStarsProject = numberOfStarsProject + 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .update({'NumberOfStars': numberOfStarsProject})
        .then((value) => print("Updated NumberOfStars In Project"))
        .catchError((error) =>
            print("Failed to update NumberOfStars In Project: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'StarredProjectIds': starredProjectIds})
        .then((value) => print("Updated StarredProjectIds"))
        .catchError(
            (error) => print("Failed to update StarredProjectIds: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'StarredProjectCount': starredProjectCount})
        .then((value) => print("Updated StarredProjectCount"))
        .catchError(
            (error) => print("Failed to update StarredProjectCount: $error"));
  }

  Future<int> getNumberOfStars(var projectId) async {
    int numberOfStars;

    CollectionReference projectsRef = firestore.collection('Projects');

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        numberOfStars = data['NumberOfStars'];
      } else {
        print('Document does not exist on the database');
      }
    });

    return numberOfStars;
  }

  Future unStar(var projectId) async {
    List starredProjectIds;
    int starredProjectCount;
    int numberOfStarsProject;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    print("UnStarring project: id is $projectId");

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        starredProjectIds = data['StarredProjectIds'];
        starredProjectIds.remove(projectId);
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        starredProjectCount = data['StarredProjectCount'];
        starredProjectCount = starredProjectCount - 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        numberOfStarsProject = data['NumberOfStars'];
        numberOfStarsProject = numberOfStarsProject - 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .update({'NumberOfStars': numberOfStarsProject})
        .then((value) => print("Updated NumberOfStars In Project"))
        .catchError((error) =>
            print("Failed to update NumberOfStars In Project: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'StarredProjectIds': starredProjectIds})
        .then((value) => print("Updated StarredProjectIds"))
        .catchError(
          (error) => print("Failed to update StarredProjectIds: $error"),
        );

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'StarredProjectCount': starredProjectCount})
        .then((value) => print("Updated StarredProjectCount"))
        .catchError(
          (error) => print("Failed to update StarredProjectCount: $error"),
        );
  }

  Future donateProject(String projectId, int amountDonated) async {
    String username;
    int donationCount;
    var donators;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        username = data['UserName'];
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        donationCount = data['AmountDonated'];
        donationCount = donationCount + amountDonated;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        donators = data['Donators'];
        var myDonation = donators[username];
        if (myDonation == null) {
          donators.addAll({username: amountDonated});
        } else {
          donators.addAll({username: myDonation + amountDonated});
        }
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Donators': donators})
        .then((value) => print("Updated Donators"))
        .catchError(
          (error) => print("Failed to update Donators: $error"),
        );

    projectsRef
        .doc(projectId)
        .update({'AmountDonated': donationCount})
        .then((value) => print("Updated AmountDonated"))
        .catchError(
          (error) => print("Failed to update AmountDonated: $error"),
        );
  }

  Future isVolunteered(String projectId) async {
    List volunteeringProjectIds;
    bool isVolunteered = false;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteeringProjectIds = data['VolunteeringProjectIds'];
        volunteeringProjectIds.forEach((volunteeredProjectIds) {
          if (volunteeredProjectIds == projectId) {
            isVolunteered = true;
          }
        });
      } else {
        print('Document does not exist on the database');
      }
    });
    return isVolunteered;
  }

  Future volunteerProject(String projectId) async {
    int volunteerCount;
    List volunteers;
    String username;
    List volunteeringProjectIds;
    int volunteerProjectCount;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteeringProjectIds = data['VolunteeringProjectIds'];
        volunteeringProjectIds.add(projectId);
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteerProjectCount = data['VolunteeringProjectCount'];
        volunteerProjectCount = volunteerProjectCount + 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'VolunteeringProjectIds': volunteeringProjectIds})
        .then((value) => print("Updated VolunteeringProjectIds"))
        .catchError((error) =>
            print("Failed to update VolunteeringProjectIds: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'VolunteeringProjectCount': volunteerProjectCount})
        .then((value) => print("Updated VolunteeringProjectCount"))
        .catchError((error) =>
            print("Failed to update VolunteeringProjectCount: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        username = data['UserName'];
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteerCount = data['NumberOfVolunteers'];
        volunteerCount = volunteerCount + 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteers = data['Volunteers'];
        volunteers.add(username);
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Volunteers': volunteers})
        .then((value) => print("Updated Volunteers"))
        .catchError(
          (error) => print("Failed to update Volunteers: $error"),
        );

    projectsRef
        .doc(projectId)
        .update({'NumberOfVolunteers': volunteerCount})
        .then((value) => print("Updated NumberOfVolunteers"))
        .catchError(
          (error) => print("Failed to update NumberOfVolunteers: $error"),
        );

    ReputationManager manager = ReputationManager();
    manager.increaseRep(auth.currentUser.uid, 30);
  }

  Future unVolunteerProject(String projectId) async {
    int volunteerCount;
    List volunteers;
    String username;
    List volunteeringProjectIds;
    int volunteerProjectCount;

    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');

    CollectionReference projectsRef = firestore.collection('Projects');

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteeringProjectIds = data['VolunteeringProjectIds'];
        volunteeringProjectIds.remove(projectId);
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteerProjectCount = data['VolunteeringProjectCount'];
        volunteerProjectCount = volunteerProjectCount - 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'VolunteeringProjectIds': volunteeringProjectIds})
        .then((value) => print("Updated VolunteeringProjectIds"))
        .catchError((error) =>
            print("Failed to update VolunteeringProjectIds: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .update({'VolunteeringProjectCount': volunteerProjectCount})
        .then((value) => print("Updated VolunteeringProjectCount"))
        .catchError((error) =>
            print("Failed to update VolunteeringProjectCount: $error"));

    await usersRef
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        username = data['UserName'];
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteerCount = data['NumberOfVolunteers'];
        volunteerCount = volunteerCount - 1;
      } else {
        print('Document does not exist on the database');
      }
    });

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        volunteers = data['Volunteers'];
        volunteers.remove(username);
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Volunteers': volunteers})
        .then((value) => print("Updated Volunteers"))
        .catchError(
          (error) => print("Failed to update Volunteers: $error"),
        );

    projectsRef
        .doc(projectId)
        .update({'NumberOfVolunteers': volunteerCount})
        .then((value) => print("Updated NumberOfVolunteers"))
        .catchError(
          (error) => print("Failed to update NumberOfVolunteers: $error"),
        );

    ReputationManager manager = ReputationManager();
    manager.decreaseRep(auth.currentUser.uid, 30);
  }

  createNewTask(String projectId, Task task) {
    firestore
        .collection('Projects')
        .doc(projectId)
        .collection('Tasks')
        .doc()
        .set({
      'Name': task.name,
      'Description': task.description,
      'RepReward': task.repReward,
      'UploadDate': task.uploadDate,
      'DueDate': task.dueDate,
      'IsComplete': false,
    });
  }

  setTaskCompleted(String projectId, String docId) {
    firestore
        .collection('Projects')
        .doc(projectId)
        .collection('Tasks')
        .doc(docId)
        .update({'IsComplete': true});
  }

  Future getUidFromName(String username) async {
    String uid;

    await firestore
        .collection('Users')
        .where('UserName', isEqualTo: username)
        .get()
        .then((QuerySnapshot snapshot) {
      var docs = snapshot.docs;
      uid = docs[0]['Uid'];
    });

    return uid;
  }

  Future reportProject(String projectId) async {
    var reports;

    CollectionReference projectsRef = firestore.collection('Projects');

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        reports = data['Reports'];
        reports.add(auth.currentUser.uid);
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Reports': reports})
        .then((value) => print("Updated Reports"))
        .catchError(
          (error) => print("Failed to update Reports: $error"),
        );
  }

  Future unReportProject(String projectId) async {
    var reports;

    CollectionReference projectsRef = firestore.collection('Projects');

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        reports = data['Reports'];
        reports.remove(auth.currentUser.uid);
      } else {
        print('Document does not exist on the database');
      }
    });

    projectsRef
        .doc(projectId)
        .update({'Reports': reports})
        .then((value) => print("Updated Reports"))
        .catchError(
          (error) => print("Failed to update Reports: $error"),
        );
  }

  Future<bool> hasReported(String projectId) async {
    bool isReported = false;
    var reports;

    CollectionReference projectsRef = firestore.collection('Projects');

    await projectsRef
        .doc(projectId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        var data = documentSnapshot.data();
        reports = data['Reports'];
        reports.forEach((uid) {
          if (uid == auth.currentUser.uid) {
            isReported = true;
          }
        });
      } else {
        print('Document does not exist on the database');
      }
    });
    return isReported;
  }

  taskIsComplete(String projectId, String docID) async {
    bool taskIsComplete = false;

    await firestore
        .collection('Projects')
        .doc(projectId)
        .collection('Tasks')
        .doc(docID)
        .get()
        .then((DocumentSnapshot snap) {
      var data = snap.data();
      print('\n\n Some DATA $data \n\n');
      taskIsComplete = data['IsComplete'];
    });
    return taskIsComplete;
  }

  getTaskLength(String projectId) {
    return firestore
        .collection('Projects')
        .doc(projectId)
        .collection('Tasks')
        .snapshots()
        .length;
  }

  Future<dynamic> getUserDoc(String uid) async {
    dynamic document;
    print("UID IS $uid");

    await FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc.id == uid) {
                  print("Returning doc: ${doc.data()}");
                  document = doc.data();
                }
              })
            });
    return document;
  }
}
