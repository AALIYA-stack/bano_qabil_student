class ProgressModel {
final int completedModules;
final int totalModules;
final double attendancePercentage;
final double assignmentAverage;

const ProgressModel({
required this.completedModules,
required this.totalModules,
required this.attendancePercentage,
required this.assignmentAverage,
});

double get modulePercentage {
if (totalModules <= 0) {
return 0;
}

return (completedModules / totalModules) * 100;
}

double get overallPercentage {
if (totalModules <= 0) {
return (
attendancePercentage +
assignmentAverage
) /
2;
}

return (
modulePercentage +
attendancePercentage +
assignmentAverage
) /
3;
}

String get overallLabel {
if (overallPercentage >= 80) {
return 'Excellent';
}

if (overallPercentage >= 60) {
return 'Good';
}

if (overallPercentage >= 40) {
return 'Needs Improvement';
}

return 'Getting Started';
}

ProgressModel copyWith({
int? completedModules,
int? totalModules,
double? attendancePercentage,
double? assignmentAverage,
}) {
return ProgressModel(
completedModules:
completedModules ?? this.completedModules,
totalModules:
totalModules ?? this.totalModules,
attendancePercentage:
attendancePercentage ??
this.attendancePercentage,
assignmentAverage:
assignmentAverage ??
this.assignmentAverage,
);
}
}
