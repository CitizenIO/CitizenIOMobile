import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  Project(
      {this.projectId,
      this.headline,
      this.description,
      this.leader,
      this.prize,
      this.city,
      this.amountDonated,
      this.donationGoal,
      this.donationsAccepted,
      this.donators,
      this.volunteers,
      this.startDate,
      this.volunteerGoal,
      this.referenceImages,
      this.numberOfVolunteers,
      this.uid,
      this.location,
      this.numberOfStars,
      this.verified,
      this.reports});

  final int numberOfVolunteers;
  final int donationGoal;
  final int amountDonated;
  final int volunteerGoal;
  final String headline;
  final String projectId;
  final String description;
  final String leader;
  final String prize;
  final String city;
  final GeoPoint location;
  final bool donationsAccepted;
  final Map donators;
  final List volunteers;
  final Timestamp startDate;
  final List referenceImages;
  final String uid;
  final int numberOfStars;
  final bool verified;
  final List reports;
}
