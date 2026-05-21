sealed class Homepagestate {}
class HomeInitialState extends Homepagestate {}
class HomeLoadingState extends Homepagestate {}
class HomeSuccessState extends Homepagestate {}
class HomeFailureState extends Homepagestate {
  final String error;
  HomeFailureState(this.error);
}