import 'package:timescape/item_manager.dart';
import 'dart:math';

class KMeansClustering {
  List<Item> items;
  int k;
  int maxIterations;

  KMeansClustering(this.items, this.k, {this.maxIterations = 100});

  double _euclideanDistance(Item a, Item b) {
    return sqrt(
        pow(a.urgency - b.urgency, 2) + pow(a.importance - b.importance, 2));
  }

  List<List<Item>> cluster() {
    List<List<Item>> quadrants = List.generate(4, (_) => []);

    // Normalize urgency values
    double maxUrgency = items.map((item) => item.urgency).reduce(max);
    for (var item in items) {
      item.urgency /= maxUrgency;
    }

    // Randomly select k initial centroids
    List<Item> centroids = items..shuffle();
    centroids = centroids.take(k).toList();

    int iteration = 0;
    bool centroidsChanged = true;

    while (centroidsChanged && iteration < maxIterations) {
      List<List<Item>> clusters = List.generate(k, (_) => []);

      // Assign each item to the nearest centroid
      for (Item item in items) {
        int nearestCentroidIndex = 0;
        double minDistance = double.infinity;

        for (int i = 0; i < k; i++) {
          double distance = _euclideanDistance(item, centroids[i]);
          if (distance < minDistance) {
            minDistance = distance;
            nearestCentroidIndex = i;
          }
        }

        clusters[nearestCentroidIndex].add(item);
      }

      // Calculate the new centroids
      List<Item> newCentroids = [];
      for (List<Item> cluster in clusters) {
        double meanUrgency =
            cluster.map((item) => item.urgency).reduce((a, b) => a + b) /
                cluster.length;
        double meanImportance =
            cluster.map((item) => item.importance).reduce((a, b) => a + b) /
                cluster.length;
        // newCentroids.add(Item(meanUrgency, meanImportance));
      }

      // Check if centroids have changed significantly
      centroidsChanged = false;
      for (int i = 0; i < k; i++) {
        if (_euclideanDistance(centroids[i], newCentroids[i]) > 1e-6) {
          centroidsChanged = true;
          break;
        }
      }

      centroids = newCentroids;
      iteration++;
    }

    // Assign items to quadrants based on urgency and importance values
    for (Item item in items) {
      if (item.urgency >= 0.5 && item.importance >= 0.5) {
        quadrants[0].add(item);
      } else if (item.urgency < 0.5 && item.importance >= 0.5) {
        quadrants[1].add(item);
      } else if (item.urgency >= 0.5 && item.importance < 0.5) {
        quadrants[2].add(item);
      } else {
        quadrants[3].add(item);
      }
    }

    return quadrants;
  }
}
