//: Playground - noun: a place where people can play

import Foundation

extension Double {
    var degreesToRadians: Double { return self * M_PI / 180 }
    var radiansToDegrees: Double { return self * 180 / M_PI }
}

//var firstCoordinate : [Double] = [-34.9462, 138.5332]
var firstCoordinate : [Double] = [-37,137] //Test Coordinates
firstCoordinate = [firstCoordinate[0].degreesToRadians,firstCoordinate[1].degreesToRadians]
//var secondCoordinate : [Double] = [-34.7024994, 138.6210022]
var secondCoordinate : [Double] = [-37,137.666666]
secondCoordinate = [secondCoordinate[0].degreesToRadians,secondCoordinate[1].degreesToRadians]

enum vincentysError : ErrorType {
    
    case coincidentCoordinates
    case incorrectCoordinates
    case antipodalCoordinates
    case unknownCoordinateError
    
}


func vincentysInverse(coordinateOne : Array<Double>, coordinateTwo : Array<Double>) throws -> Array<Double>{
    
    if abs(coordinateOne[0])>M_PI/2 || abs(coordinateTwo[0])>M_PI/2 || abs(coordinateOne[1])>M_PI || abs(coordinateTwo[1])>M_PI{
        throw vincentysError.incorrectCoordinates
    }
    
    if coordinateOne == coordinateTwo{
        throw vincentysError.coincidentCoordinates
    }
    
    
    if coordinateOne[0] == -coordinateTwo[0] && abs(coordinateOne[1]-coordinateTwo[1]) == M_PI{
        throw vincentysError.antipodalCoordinates
    }
    else if abs(coordinateOne[1]) == 90 && abs(coordinateTwo[1])==90{
        throw vincentysError.antipodalCoordinates
    }
    
    func bearingDecimalToString(bearingDecimal : Double) -> String{
        let bearingDegree = floor(bearingDecimal)
        let bearingMinuteSecond = (bearingDecimal-bearingDegree)*100
        let bearingMinute = floor(bearingMinuteSecond*0.6)
        let bearingSecond = (bearingMinuteSecond-floor(bearingMinuteSecond))*60
        let bearingString : String = "Bearing: \(Int(bearingDegree)) Degrees, \(Int(bearingMinute)) Minutes and \(Int(round(bearingSecond))) Seconds"
        return bearingString
    }
    
    let a : Double = 3443.930885529 //Earths Equatorial Radius in nm
    let f : Double = 1/298.25722210 //Flatening of the earth
    let b : Double = (1-f)*a //Earths Minor Axis
    
    
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
    
    let uSquare = cosSquareAlpha*(pow(a,2)-pow(b,2))/pow(b,2)
    let capitalA = 1 + (uSquare/16384)*(4096 + uSquare*(-768 + uSquare*(320 - 175*uSquare)))
    let capitalB = (uSquare/1024)*(256 + uSquare*(-128 + uSquare*(74 - 47*uSquare)))
    let deltaSigma = capitalB * sinSigma * (cos2SigmaM + 0.25*capitalB*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM))-(1/6)*capitalB*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM))
    let lowerCaseS = b*capitalA*(sigma-deltaSigma)
    
    let alphaOne = atan2((cos(reducedLatitudeTwo)*sin(lambda)) , (cos(reducedLatitudeOne)*sin(reducedLatitudeTwo) - sin(reducedLatitudeOne)*cos(reducedLatitudeTwo)*cos(lambda))).radiansToDegrees
    
    let alphaTwo = atan2((cos(reducedLatitudeOne)*sin(lambda)) , (-sin(reducedLatitudeOne)*cos(reducedLatitudeTwo) + cos(reducedLatitudeOne)*sin(reducedLatitudeTwo)*cos(lambda))).radiansToDegrees + 180
    
    print(bearingDecimalToString(alphaOne))
    print(bearingDecimalToString(alphaTwo))
    print("Distance: \(round(lowerCaseS*100)/100) nm")
    
    return [lowerCaseS,alphaOne,alphaTwo]
}

do{
    

try vincentysInverse(firstCoordinate, coordinateTwo: secondCoordinate)
}

catch vincentysError.coincidentCoordinates{
    print("Coordinates are Coincident")
}

catch vincentysError.antipodalCoordinates{
    print("Coordinates are Antipodal")
}

catch vincentysError.incorrectCoordinates{
    print("Please insert correct coordinates")
}
//Test

