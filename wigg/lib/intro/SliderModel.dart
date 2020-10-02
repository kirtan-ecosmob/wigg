import 'package:flutter/material.dart';


class SliderModel{

//  String imageAssetPath;
  String title;
  String desc;

//  SliderModel({this.imageAssetPath,this.title,this.desc});

  SliderModel({this.title,this.desc});

//  void setImageAssetPath(String getImageAssetPath){
//    imageAssetPath = getImageAssetPath;
//  }

  void setTitle(String getTitle){
    title = getTitle;
  }

  void setDesc(String getDesc){
    desc = getDesc;
  }

//  String getImageAssetPath(){
//    return imageAssetPath;
//  }

  String getTitle(){
    return title;
  }

  String getDesc(){
    return desc;
  }

}


List<SliderModel> getSlides(){

  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();

  //1
  sliderModel.setDesc("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s,");
  sliderModel.setTitle("");
//  sliderModel.setImageAssetPath("assets/illustration.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //2
  sliderModel.setDesc("dustry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s,");
  sliderModel.setTitle("");
//  sliderModel.setImageAssetPath("assets/illustration2.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //3
  sliderModel.setDesc("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s,");
  sliderModel.setTitle("");
//  sliderModel.setImageAssetPath("assets/illustration3.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  return slides;
}