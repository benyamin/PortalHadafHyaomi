//
//  MesurementsManager.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 29/04/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
 public enum MeasurementType:Int {
    case volume
    case length
    case surface
    case weight
}

open class  MesurementsManager
{
    static let sharedManager =   MesurementsManager()
    
    static let beytza:Double = 1
    static let zait:Double = 1/2 * beytza
    static let gorgeret:Double = 1/3 * beytza
    static let kotevet:Double = 2/3 * beytza
    static let pratz:Double = 3 * beytza
    static let kav:Double = 24 * beytza
    static let log:Double = 6 * beytza
    static let rova:Double = 1/4 * kav
    static let seia:Double = 6 * kav
    static let kortove = 1/64 * log
    static let hin:Double = 12 * log
    static let shminit:Double = 1/8 * log
    static let reviet:Double = 0.25 * log
    static let ochla:Double = 1/2 * reviet
    static let litra:Double = 2 * reviet
    static let omer:Double = 1/10 * eyfa
    static let eyfa:Double = 3 * seia
    static let letech:Double = 15 * seia
    static let kor:Double = 30 * seia
    
    static let etzba:Double = 1
    static let tefach:Double = 4 * etzba
    static let sit:Double = 2 * tefach
    static let zeret:Double = 3 * tefach
    static let ama:Double = 6 * tefach
    static let ris:Double = 800 * sit
    static let mil:Double = 2000 * ama
    static let hilochShah:Double = 25 * ris
    static let parsa:Double = 4 * mil
    
    static let baitSeia:Double = 50 * 50 * ama
    static let baitRova:Double = 1/4 * baitKav
    static let baitKav:Double = 1/6 * baitSeia
    static let baitSatim:Double = 2 * baitSeia
    static let baitKor:Double = 30 * baitSeia
    
    static let prota:Double = 1
    static let isar:Double = 8 * prota
    static let pondiun:Double = 2 * isar
    static let mea:Double = 2 * pondiun
    static let trapic:Double = 3 * mea
    static let dinar:Double = 2 * trapic
    static let shekel:Double = 2 * dinar
    static let sela:Double = 2 * shekel
    static let darkon:Double = 2 * sela
    static let mane:Double = 25 * sela
    
    static let centimeter:Double = 0.5 * etzba
    static let millimeter:Double = 0.1 * centimeter
    static let meter:Double = 100 * centimeter
    static let kilometer:Double = 1000 * meter
    static let mile:Double = 1.609344 * kilometer
    static let yard:Double = 0.9144 * meter
    static let inch:Double = 2.54 * centimeter
    static let foot:Double = 0.3048 * meter
    
    static let liter:Double = kav*1.4
    static let cubicCentimeter:Double = liter*0.001
    static let gallon:Double = 3.78541 * liter
    
    static let gram:Double = 40 * prota
    static let kilogram:Double = 1000 * gram
    static let pound:Double = 0.4536 * kilogram
    
    static let squareMetre:Double = baitSeia * 0.001736111111
    static let dunam:Double = squareMetre * 1000
    static let acre:Double = dunam * 4.0468564224
    static let squareFoot:Double = acre * 0.00002295
    
    //מידות נפח
 
    static let volumeMeasurementsKeys:[String] = {
        
        var volumeMeasurementsKeys = [String]()
        
        volumeMeasurementsKeys.append("kortove")
        volumeMeasurementsKeys.append("gorgeret")
        volumeMeasurementsKeys.append("zait")
        volumeMeasurementsKeys.append("kotevet")
        volumeMeasurementsKeys.append("ochla")
        volumeMeasurementsKeys.append("shminit")
        volumeMeasurementsKeys.append("beytza")
        volumeMeasurementsKeys.append("reviet")
        volumeMeasurementsKeys.append("pratz")
        volumeMeasurementsKeys.append("litra")
        volumeMeasurementsKeys.append("log")
        volumeMeasurementsKeys.append("rova")
        volumeMeasurementsKeys.append("kav")
        volumeMeasurementsKeys.append("omer")
        volumeMeasurementsKeys.append("hin")
        volumeMeasurementsKeys.append("seia")
        volumeMeasurementsKeys.append("eyfa")
        volumeMeasurementsKeys.append("letech")
        volumeMeasurementsKeys.append("kor")
        volumeMeasurementsKeys.append("liter")
        volumeMeasurementsKeys.append("gallon")
        
         return volumeMeasurementsKeys
    }()
    
    static let volumeMeasurements:[String:Double] = {
        
        var volumeMeasurements = [String:Double]()
        
        volumeMeasurements["kortove"] = kortove
        volumeMeasurements["gorgeret"] = gorgeret
        volumeMeasurements["zait"] = zait
        volumeMeasurements["kotevet"] = kotevet
        volumeMeasurements["ochla"] = ochla
        volumeMeasurements["shminit"] = shminit
        volumeMeasurements["beytza"] = beytza
        volumeMeasurements["reviet"] = reviet
        volumeMeasurements["pratz"] = pratz
        volumeMeasurements["litra"] = litra
        volumeMeasurements["log"] = log
        volumeMeasurements["rova"] = rova
        volumeMeasurements["kav"] = kav
        volumeMeasurements["omer"] = omer
        volumeMeasurements["hin"] = hin
        volumeMeasurements["seia"] = seia
        volumeMeasurements["eyfa"] = eyfa
        volumeMeasurements["letech"] = letech
        volumeMeasurements["kor"] = kor
        
        volumeMeasurements["liter"] = liter
        volumeMeasurements["cubicCentimeter"] = cubicCentimeter
        volumeMeasurements["gallon"] =  gallon
        
        return volumeMeasurements
    }()
    
    
    static let modern_volumeMeasurementsKeys:[String] = {
        
        var volumeMeasurementsKeys = [String]()
        
        volumeMeasurementsKeys.append("liter")
        volumeMeasurementsKeys.append("cubicCentimeter")
        volumeMeasurementsKeys.append("gallon")
        
        return volumeMeasurementsKeys
    }()
    

//מידות אורך
   
    static let lengthMeasurementsKeys:[String] = {
        
        var lengthMeasurementsKeys = [String]()
        
        lengthMeasurementsKeys.append("etzba")
        lengthMeasurementsKeys.append("tefach")
        lengthMeasurementsKeys.append("sit")
        lengthMeasurementsKeys.append("zeret")
        lengthMeasurementsKeys.append("ama")
        lengthMeasurementsKeys.append("ris")
        lengthMeasurementsKeys.append("mil")
        lengthMeasurementsKeys.append("hilochShah")
        lengthMeasurementsKeys.append("parsa")
        
        lengthMeasurementsKeys.append("millimeter")
        lengthMeasurementsKeys.append("centimeter")
        lengthMeasurementsKeys.append("meter")
        lengthMeasurementsKeys.append("kilometer")
        lengthMeasurementsKeys.append("mile")
        lengthMeasurementsKeys.append("yard")
        lengthMeasurementsKeys.append("inch")
        lengthMeasurementsKeys.append("foot")
        
        return lengthMeasurementsKeys
    }()
    
    static let lengthMeasurements:[String:Double] = {
        
        var lengthMeasurements = [String:Double]()
        
        lengthMeasurements["etzba"] = etzba
        lengthMeasurements["tefach"] = tefach
        lengthMeasurements["sit"] = sit
        lengthMeasurements["zeret"] = zeret
        lengthMeasurements["ama"] = ama
        lengthMeasurements["ris"] = ris
        lengthMeasurements["mil"] = mil
        lengthMeasurements["hilochShah"] = hilochShah
        lengthMeasurements["parsa"] = parsa
        
        lengthMeasurements["meter"] = meter
        lengthMeasurements["centimeter"] = centimeter
        lengthMeasurements["millimeter"] = millimeter
        lengthMeasurements["kilometer"] = kilometer
        lengthMeasurements["mile"] = mile
        lengthMeasurements["yard"] = yard
        lengthMeasurements["inch"] = inch
        lengthMeasurements["foot"] = foot
        
        return lengthMeasurements
    }()
    
    static let modern_lengthMeasurementsKeys:[String] = {
        
        var lengthMeasurementsKeys = [String]()
        
        lengthMeasurementsKeys.append("millimeter")
        lengthMeasurementsKeys.append("centimeter")
        lengthMeasurementsKeys.append("meter")
        lengthMeasurementsKeys.append("kilometer")
        lengthMeasurementsKeys.append("mile")
        lengthMeasurementsKeys.append("yard")
        lengthMeasurementsKeys.append("inch")
        lengthMeasurementsKeys.append("foot")
        
        return lengthMeasurementsKeys
    }()
    
    //מידות שטח
    
    static let surfaceMeasurementsKeys:[String] = {
        
        var surfaceMeasurementsKeys = [String]()
        
        surfaceMeasurementsKeys.append("baitRova")
        surfaceMeasurementsKeys.append("baitKav")
        surfaceMeasurementsKeys.append("baitSeia")
        surfaceMeasurementsKeys.append("baitSatim")
        surfaceMeasurementsKeys.append("baitKor")
        
        surfaceMeasurementsKeys.append("dunam")
        surfaceMeasurementsKeys.append("acre")
        surfaceMeasurementsKeys.append("squareMetre")
        surfaceMeasurementsKeys.append("squareFoot")
        
        return surfaceMeasurementsKeys
    }()
    
    static let surfaceMeasurements:[String:Double] = {
        
        var surfaceMeasurements = [String:Double]()
        
        surfaceMeasurements["baitRova"] = baitRova
        surfaceMeasurements["baitKav"] = baitKav
        surfaceMeasurements["baitSeia"] = baitSeia
        surfaceMeasurements["baitSatim"] = baitSatim
        surfaceMeasurements["baitKor"] = baitKor
        
        surfaceMeasurements["dunam"] = dunam
        surfaceMeasurements["acre"] = acre
        surfaceMeasurements["squareMetre"] = squareMetre
        surfaceMeasurements["squareFoot"] = squareFoot
        
        return surfaceMeasurements
    }()
    
    static let modern_surfaceMeasurementsKeys:[String] = {
        
        var volumeMeasurementsKeys = [String]()
        
        volumeMeasurementsKeys.append("dunam")
        volumeMeasurementsKeys.append("acre")
        volumeMeasurementsKeys.append("squareMetre")
        volumeMeasurementsKeys.append("squareFoot")
        
        return volumeMeasurementsKeys
    }()
    
    //מידות משקל
   
    static let weightMeasurementsKeys:[String] = {
        
        var weightMeasurementsKeys = [String]()
        
       weightMeasurementsKeys.append("prota")
       weightMeasurementsKeys.append("isar")
       weightMeasurementsKeys.append("pondiun")
       weightMeasurementsKeys.append("mea")
       weightMeasurementsKeys.append("trapic")
       weightMeasurementsKeys.append("dinar")
       weightMeasurementsKeys.append("shekel")
       weightMeasurementsKeys.append("sela")
       weightMeasurementsKeys.append("darkon")
       weightMeasurementsKeys.append("mane")
        
        weightMeasurementsKeys.append("gram")
       weightMeasurementsKeys.append("kilogram")
       weightMeasurementsKeys.append("pound")
        
        return weightMeasurementsKeys
    }()
    
    static let weightMeasurements:[String:Double] = {
        
        var weightMeasurements = [String:Double]()
        
        weightMeasurements["prota"] = prota
        weightMeasurements["isar"] = isar
        weightMeasurements["pondiun"] = pondiun
        weightMeasurements["mea"] = mea
        weightMeasurements["trapic"] = trapic
        weightMeasurements["dinar"] = dinar
        weightMeasurements["shekel"] = shekel
        weightMeasurements["sela"] = sela
        weightMeasurements["darkon"] = darkon
        weightMeasurements["mane"] = mane
        
        weightMeasurements["gram"] = gram
        weightMeasurements["kilogram"] = kilogram
        weightMeasurements["pound"] = pound
        
        return weightMeasurements
    }()
    
    func convertFrom(mesurment_a_name:String, amountA:Double, to mesurment_b_name:String, measurementType:MeasurementType) -> Double?
    {
        var measurementsDictoinary:[String:Double]
        
        switch measurementType {
        case .volume:
            measurementsDictoinary = MesurementsManager.volumeMeasurements
            break
            
        case .length:
             measurementsDictoinary = MesurementsManager.lengthMeasurements
             
            break
            
        case .surface:
              measurementsDictoinary = MesurementsManager.surfaceMeasurements
            break
            
        case .weight:
             measurementsDictoinary = MesurementsManager.weightMeasurements
            break
            
        }
        if let mesurmentA = measurementsDictoinary[mesurment_a_name]
          ,let mesurmentB = measurementsDictoinary[mesurment_b_name]
        {
                let conversionValue = (mesurmentA/mesurmentB) * amountA //(mesurmentA * amountA)/mesurmentB
                
                return conversionValue
        }
        
        return nil
    }
}

