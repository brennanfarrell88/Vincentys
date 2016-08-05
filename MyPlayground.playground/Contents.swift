//: Playground - noun: a place where people can play

import Foundation

extension Double {
    var degreesToRadians: Double { return self * M_PI / 180 }
    var radiansToDegrees: Double { return self * 180 / M_PI }
}

let a : Double = 3443.930885529 //Earths Equatorial Radius in nm
let f : Double = 1/298.25722210 //Flatening of the earth
let b : Double = (1-f)*a //Earths Minor Axis

//var coordinateOne : [Double] = [-34.9462, 138.5332]
var coordinateOne : [Double] = [-37,137] //Test Coordinates
coordinateOne = [coordinateOne[0].degreesToRadians,coordinateOne[1].degreesToRadians]
//var coordinateTwo : [Double] = [-34.7024994, 138.6210022]
var coordinateTwo : [Double] = [-37,137.66666666]
coordinateTwo = [coordinateTwo[0].degreesToRadians,coordinateTwo[1].degreesToRadians]
var sinSigma : Double!
var cosSigma : Double!
var sigma : Double!
var sinAlpha : Double!
var cosSquareAlpha : Double!
var cos2SigmaM : Double!
var capitalC : Double!
var lambda1 : Double!

let reducedLatitudeOne = atan((1-f)*tan(coordinateOne[0]))
let reducedLatitudeTwo = atan((1-f)*tan(coordinateTwo[0]))
let longitudeDifference = coordinateTwo[1] - coordinateOne[1]
var lambda : Double = longitudeDifference
var lambdaConvergence : Double = 1

var k : Int = 0

while lambdaConvergence > pow(10,-12){
    sinSigma = sqrt(pow((cos(reducedLatitudeTwo)*sin(lambda)),2)+pow((cos(reducedLatitudeOne)*sin(reducedLatitudeTwo)-sin(reducedLatitudeOne)*cos(reducedLatitudeTwo)*cos(lambda)),2))
    if k < 100 {
        cosSigma = sin(reducedLatitudeOne)*sin(reducedLatitudeTwo) + cos(reducedLatitudeOne)*cos(reducedLatitudeTwo)*cos(lambda)
    }
    else if k < 200{
        cosSigma = -sqrt(1-pow(sinSigma,2))
    }
    else{
        ErrorType.self
    }
    sigma = atan2(sinSigma,cosSigma)
    sinAlpha = (cos(reducedLatitudeOne)*cos(reducedLatitudeTwo)*sin(lambda))/sinSigma
    cosSquareAlpha = 1 - pow(sinAlpha,2)
    cos2SigmaM = cosSigma-((2*sin(reducedLatitudeOne)*sin(reducedLatitudeTwo))/cosSquareAlpha)
    if cos2SigmaM.isNaN{
        capitalC = 0
        cos2SigmaM = -1
    }
    else{
        capitalC = (f/16)*cosSquareAlpha*(4+f*(4-3*cosSquareAlpha))
    }
    
    lambda1 = longitudeDifference + (1-capitalC)*f*sinAlpha*(sigma + capitalC*sinSigma*cos2SigmaM + capitalC*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM))
    lambdaConvergence = abs(lambda1-lambda)
    lambda = lambda1
    k = k.advancedBy(1)
}

var uSquare = cosSquareAlpha*(pow(a,2)-pow(b,2))/pow(b,2)
var capitalA = 1 + (uSquare/16384)*(4096 + uSquare*(-768 + uSquare*(320 - 175*uSquare)))
var capitalB = (uSquare/1024)*(256 + uSquare*(-128 + uSquare*(74 - 47*uSquare)))
var deltaSigma = capitalB * sinSigma * (cos2SigmaM + 0.25*capitalB*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM))-(1/6)*capitalB*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM))
var lowerCaseS = b*capitalA*(sigma-deltaSigma)

var alphaOne = atan((cos(reducedLatitudeTwo)*sin(lambda)) / (cos(reducedLatitudeOne)*sin(reducedLatitudeTwo) - sin(reducedLatitudeOne)*cos(reducedLatitudeTwo)*cos(lambda))).radiansToDegrees + 360

var alphaTwo = atan((cos(reducedLatitudeOne)*sin(lambda)) / (-sin(reducedLatitudeOne)*cos(reducedLatitudeTwo) + cos(reducedLatitudeOne)*sin(reducedLatitudeTwo)*cos(lambda))).radiansToDegrees

//Test commmit

