class Plant {
  int healthLevel;
  int waterLevel;
  DateTime lastWatered;
  int rewardPoints;

  Plant({
    this.healthLevel = 100,
    this.waterLevel = 100,
    required this.lastWatered,
    this.rewardPoints = 0,
  });
}