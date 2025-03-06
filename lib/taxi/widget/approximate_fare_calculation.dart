import '../../network/services.dart';
import '../../taxi/data/nearest_drivers_list_api_data.dart';
import '../../widget/utils/enums.dart';
import '../controller/taxi_controller.dart';

double doubleWithTwoDigits(double value) =>
    double.parse(value.toStringAsFixed(2));

void calculateApproximateFare(
    List<CarModelData> fareDetailsList, TaxiController taxiController) {
  try {
    double distance = taxiController.approximateDistance.value;
    double time = taxiController.approximateTime.value;
    double trafficTime = taxiController.approximateTrafficTime.value;

    for (CarModelData fareDetails in fareDetailsList) {
      num approximateFareMin = 0.0;
      num approximateFareMax = 0.0;
      num minimumFare = fareDetails.minFare ?? 0;
      num belowAboveKm = fareDetails.belowAboveKm ?? 0;

      // Calculate the minimum fare
      if (distance <= belowAboveKm) {
        approximateFareMin = (distance * (fareDetails.belowKm ?? 0)) +
            (fareDetails.baseFare ?? 0);
      } else {
        approximateFareMin = (distance * (fareDetails.aboveKm ?? 0)) +
            (fareDetails.baseFare ?? 0);
      }

      // Calculate time-based fare for minimum fare
      if (fareDetails.fareCalculationType == 3 ||
          fareDetails.fareCalculationType == 2) {
        if (fareDetails.minutesFare != null) {
          approximateFareMin += time * fareDetails.minutesFare!;
        }
      }

      // Apply night and evening charges for minimum fare
      if (fareDetails.nightCharge == 1 && fareDetails.nightFare != null) {
        approximateFareMin +=
            approximateFareMin * (fareDetails.nightFare! * 0.01);
      }
      if (fareDetails.eveningCharge == 1 && fareDetails.eveningFare != null) {
        approximateFareMin +=
            approximateFareMin * (fareDetails.eveningFare! * 0.01);
      }

      // Ensure minimum fare is respected
      if (approximateFareMin < minimumFare) {
        approximateFareMin = minimumFare;
      }

      // Add toll and additional fares for minimum fare
      approximateFareMin += (fareDetails.tollFare ?? 0) +
          (fareDetails.additionalFare ?? 0);

      // Calculate the maximum fare (including waiting time)
      num waitingFare = 0;
      double waitingDuration = (trafficTime - time) / 2;
      if (waitingDuration > 0 &&
          fareDetails.waitingFare != null &&
          fareDetails.waitingFare! > 0) {
        waitingFare = waitingDuration * fareDetails.waitingFare!;
      }

      // Start with the minimum fare and add waiting charges
      approximateFareMax = approximateFareMin + waitingFare;

      // Ensure max fare is higher than min fare
      if (approximateFareMax <= approximateFareMin) {
        approximateFareMax = approximateFareMin + 10; // Fallback to static margin
      }

      // Update the car model with the calculated fares
      taxiController.carModelList
        ..forEach((item) {
          if (item.modelId == fareDetails.modelId) {
            item.approximateFare = approximateFareMin.round();
            item.approximateFareWithWaitingFare = approximateFareMax.round();
          }
        })
        ..refresh();
    }

    taxiController.distanceCalculated.value =
        ApproximateDistanceCalculated.kCompleted;
  } catch (e) {
    printLogs('ApproxFare calculation error -> $e');
  }
}
