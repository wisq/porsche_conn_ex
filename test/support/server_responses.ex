defmodule PorscheConnEx.Test.ServerResponses do
  # A collection of response bodies, mostly taken verbatim from the API.
  # Some personally identifiable information has been changed.

  def action_in_progress(req_id) do
    """
    {
      "actionId" : "#{req_id}",
      "actionState" : "IN_PROGRESS"
    }
    """
  end

  def action_success(req_id) do
    """
    {
      "actionId" : "#{req_id}",
      "actionState" : "SUCCESS"
    }
    """
  end

  def request_id(req_id) do
    """
    {
      "requestId" : "#{req_id}"
    }
    """
  end

  def status_in_progress do
    """
    {
      "status" : "IN_PROGRESS"
    }
    """
  end

  def status_failed do
    """
    {
      "status" : "FAIL"
    }
    """
  end

  def status_success do
    """
    {
      "status" : "SUCCESSFUL"
    }
    """
  end

  def vehicles(vin, nickname \\ nil) do
    attributes =
      case nickname do
        nil ->
          """
            "attributes" : [ ],
          """

        nn when is_binary(nn) ->
          """
            "attributes" : [ {
              "name" : "licenseplate",
              "value" : "#{nn}"
            } ],
          """
      end

    """
    [ {
      "vin" : "#{vin}",
      "isPcc" : true,
      "relationship" : "OWNER",
      "modelDescription" : "Taycan GTS",
      "modelType" : "Y1ADE1",
      "modelYear" : "2022",
      "exteriorColor" : "vulkangraumetallic/vulkangraumetallic",
      "exteriorColorHex" : "#252625",
      "spinEnabled" : true,
      "loginMethod" : "PORSCHE_ID",
      "pendingRelationshipTerminationAt" : null,
      #{attributes |> String.trim()}
      "otaActive" : true,
      "validFrom" : "2024-01-01T01:02:03.000Z"
    } ]
    """
  end

  def status(vin) do
    """
    {
      "vin" : "#{vin}",
      "fuelLevel" : null,
      "oilLevel" : null,
      "batteryLevel" : {
        "value" : 80,
        "unit" : "PERCENT",
        "unitTranslationKey" : "GRAY_SLICE_UNIT_PERCENT",
        "unitTranslationKeyV2" : "TC.UNIT.PERCENT"
      },
      "mileage" : {
        "value" : 9001,
        "unit" : "KILOMETERS",
        "originalValue" : 9001,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 9001,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "overallLockStatus" : "CLOSED_LOCKED",
      "serviceIntervals" : {
        "oilService" : {
          "distance" : null,
          "time" : null
        },
        "inspection" : {
          "distance" : {
            "value" : -21300,
            "unit" : "KILOMETERS",
            "originalValue" : -21300,
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : -21300,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "time" : {
            "value" : -113,
            "unit" : "DAYS",
            "unitTranslationKey" : "GRAY_SLICE_UNIT_DAY",
            "unitTranslationKeyV2" : "TC.UNIT.DAYS"
          }
        }
      },
      "remainingRanges" : {
        "conventionalRange" : {
          "distance" : null,
          "engineType" : "UNSUPPORTED"
        },
        "electricalRange" : {
          "distance" : {
            "value" : 247,
            "unit" : "KILOMETERS",
            "originalValue" : 247,
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : 247,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "engineType" : "ELECTRIC"
        }
      }
    }
    """
  end

  def summary(nickname \\ nil) do
    nn_json =
      case nickname do
        nil -> "null"
        nn when is_binary(nn) -> ~s["#{nn}"]
      end

    """
    {
      "modelDescription" : "Taycan GTS",
      "nickName" : #{nn_json}
    }
    """
  end

  def overview(vin, with_tires \\ true) do
    """
    {
      "vin" : "#{vin}",
      "oilLevel" : null,
      "fuelLevel" : null,
      "batteryLevel" : {
        "value" : 80,
        "unit" : "PERCENT",
        "unitTranslationKey" : "GRAY_SLICE_UNIT_PERCENT",
        "unitTranslationKeyV2" : "TC.UNIT.PERCENT"
      },
      "remainingRanges" : {
        "conventionalRange" : {
          "distance" : null,
          "engineType" : "UNSUPPORTED",
          "isPrimary" : false
        },
        "electricalRange" : {
          "distance" : {
            "value" : 247,
            "unit" : "KILOMETERS",
            "originalValue" : 247,
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : 247,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "engineType" : "ELECTRIC",
          "isPrimary" : true
        }
      },
      "mileage" : {
        "value" : 9001,
        "unit" : "KILOMETERS",
        "originalValue" : 9001,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 9001,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "parkingLight" : "OFF",
      "parkingLightStatus" : null,
      "parkingBreak" : "INACTIVE",
      "parkingBreakStatus" : null,
      "doors" : {
        "frontLeft" : "CLOSED_LOCKED",
        "frontRight" : "CLOSED_LOCKED",
        "backLeft" : "CLOSED_LOCKED",
        "backRight" : "CLOSED_LOCKED",
        "frontTrunk" : "CLOSED_UNLOCKED",
        "backTrunk" : "CLOSED_LOCKED",
        "overallLockStatus" : "CLOSED_LOCKED"
      },
      "serviceIntervals" : {
        "oilService" : null,
        "inspection" : {
          "distance" : {
            "value" : -21300,
            "unit" : "KILOMETERS",
            "originalValue" : -21300,
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : -21300,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "time" : {
            "value" : -113,
            "unit" : "DAYS",
            "unitTranslationKey" : "GRAY_SLICE_UNIT_DAY",
            "unitTranslationKeyV2" : "TC.UNIT.DAYS"
          }
        }
      },
      #{overview_tires(with_tires) |> String.trim()},
      "windows" : {
        "frontLeft" : "CLOSED",
        "frontRight" : "CLOSED",
        "backLeft" : "CLOSED",
        "backRight" : "CLOSED",
        "roof" : "UNSUPPORTED",
        "maintenanceHatch" : "UNSUPPORTED",
        "sunroof" : {
          "status" : "UNSUPPORTED",
          "positionInPercent" : null
        }
      },
      "parkingTime" : "17.01.2024 21:48:10",
      "overallOpenStatus" : "CLOSED",
      "chargingStatus" : "CHARGING_COMPLETED",
      "carModel" : "J1",
      "engineType" : "BEV",
      "chargingState" : "COMPLETED"
    }
    """
  end

  defp overview_tires(true) do
    """
      "tires" : {
        "frontLeft" : {
          "currentPressure" : {
            "value" : 2.4,
            "unit" : "BAR",
            "valueInBar" : 2.4,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "optimalPressure" : {
            "value" : 2.7,
            "unit" : "BAR",
            "valueInBar" : 2.7,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "differencePressure" : {
            "value" : 0.3,
            "unit" : "BAR",
            "valueInBar" : 0.3,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        },
        "frontRight" : {
          "currentPressure" : {
            "value" : 2.4,
            "unit" : "BAR",
            "valueInBar" : 2.4,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "optimalPressure" : {
            "value" : 2.7,
            "unit" : "BAR",
            "valueInBar" : 2.7,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "differencePressure" : {
            "value" : 0.3,
            "unit" : "BAR",
            "valueInBar" : 0.3,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        },
        "backLeft" : {
          "currentPressure" : {
            "value" : 2.3,
            "unit" : "BAR",
            "valueInBar" : 2.3,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "optimalPressure" : {
            "value" : 2.5,
            "unit" : "BAR",
            "valueInBar" : 2.5,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "differencePressure" : {
            "value" : 0.2,
            "unit" : "BAR",
            "valueInBar" : 0.2,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        },
        "backRight" : {
          "currentPressure" : {
            "value" : 2.3,
            "unit" : "BAR",
            "valueInBar" : 2.3,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "optimalPressure" : {
            "value" : 2.4,
            "unit" : "BAR",
            "valueInBar" : 2.4,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "differencePressure" : {
            "value" : 0.1,
            "unit" : "BAR",
            "valueInBar" : 0.1,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_BAR",
            "unitTranslationKeyV2" : "TC.UNIT.BAR"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        }
      }
    """
  end

  defp overview_tires(false) do
    """
      "tires" : {
        "frontLeft" : {
          "currentPressure" : null,
          "optimalPressure" : null,
          "differencePressure" : null,
          "tirePressureDifferenceStatus" : "UNKNOWN"
        },
        "frontRight" : {
          "currentPressure" : null,
          "optimalPressure" : null,
          "differencePressure" : null,
          "tirePressureDifferenceStatus" : "UNKNOWN"
        },
        "backLeft" : {
          "currentPressure" : null,
          "optimalPressure" : null,
          "differencePressure" : null,
          "tirePressureDifferenceStatus" : "UNKNOWN"
        },
        "backRight" : {
          "currentPressure" : null,
          "optimalPressure" : null,
          "differencePressure" : null,
          "tirePressureDifferenceStatus" : "UNKNOWN"
        }
      }
    """
  end

  def overview_US(vin) do
    """
    {
      "vin" : "#{vin}",
      "oilLevel" : null,
      "fuelLevel" : null,
      "batteryLevel" : {
        "value" : 80,
        "unit" : "PERCENT",
        "unitTranslationKey" : "GRAY_SLICE_UNIT_PERCENT",
        "unitTranslationKeyV2" : "TC.UNIT.PERCENT"
      },
      "remainingRanges" : {
        "conventionalRange" : {
          "distance" : null,
          "engineType" : "UNSUPPORTED",
          "isPrimary" : false
        },
        "electricalRange" : {
          "distance" : {
            "value" : 159.6924,
            "unit" : "MILES",
            "originalValue" : 159.6924,
            "originalUnit" : "MILES",
            "valueInKilometers" : 257,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
            "unitTranslationKeyV2" : "TC.UNIT.MILES"
          },
          "engineType" : "ELECTRIC",
          "isPrimary" : true
        }
      },
      "mileage" : {
        "value" : 5533.31,
        "unit" : "MILES",
        "originalValue" : 8905,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 8905,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "parkingLight" : "OFF",
      "parkingLightStatus" : null,
      "parkingBreak" : "ACTIVE",
      "parkingBreakStatus" : null,
      "doors" : {
        "frontLeft" : "CLOSED_LOCKED",
        "frontRight" : "CLOSED_LOCKED",
        "backLeft" : "CLOSED_LOCKED",
        "backRight" : "CLOSED_LOCKED",
        "frontTrunk" : "CLOSED_UNLOCKED",
        "backTrunk" : "CLOSED_LOCKED",
        "overallLockStatus" : "CLOSED_LOCKED"
      },
      "serviceIntervals" : {
        "oilService" : null,
        "inspection" : {
          "distance" : {
            "value" : -13173.07,
            "unit" : "MILES",
            "originalValue" : -21200,
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : -21200,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
            "unitTranslationKeyV2" : "TC.UNIT.MILES"
          },
          "time" : {
            "value" : -103,
            "unit" : "DAYS",
            "unitTranslationKey" : "GRAY_SLICE_UNIT_DAY",
            "unitTranslationKeyV2" : "TC.UNIT.DAYS"
          }
        }
      },
      "tires" : {
        "frontLeft" : {
          "currentPressure" : {
            "value" : 36.25943,
            "unit" : "PSI",
            "valueInBar" : 2.5,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "optimalPressure" : {
            "value" : 40.61057,
            "unit" : "PSI",
            "valueInBar" : 2.8,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "differencePressure" : {
            "value" : 4.351132,
            "unit" : "PSI",
            "valueInBar" : 0.3,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        },
        "frontRight" : {
          "currentPressure" : {
            "value" : 36.25943,
            "unit" : "PSI",
            "valueInBar" : 2.5,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "optimalPressure" : {
            "value" : 40.61057,
            "unit" : "PSI",
            "valueInBar" : 2.8,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "differencePressure" : {
            "value" : 4.351132,
            "unit" : "PSI",
            "valueInBar" : 0.3,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        },
        "backLeft" : {
          "currentPressure" : {
            "value" : 34.80906,
            "unit" : "PSI",
            "valueInBar" : 2.4,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "optimalPressure" : {
            "value" : 37.70981,
            "unit" : "PSI",
            "valueInBar" : 2.6,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "differencePressure" : {
            "value" : 2.900755,
            "unit" : "PSI",
            "valueInBar" : 0.2,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        },
        "backRight" : {
          "currentPressure" : {
            "value" : 34.80906,
            "unit" : "PSI",
            "valueInBar" : 2.4,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "optimalPressure" : {
            "value" : 37.70981,
            "unit" : "PSI",
            "valueInBar" : 2.6,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "differencePressure" : {
            "value" : 2.900755,
            "unit" : "PSI",
            "valueInBar" : 0.2,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_PSI",
            "unitTranslationKeyV2" : "TC.UNIT.PSI"
          },
          "tirePressureDifferenceStatus" : "DIVERGENT"
        }
      },
      "windows" : {
        "frontLeft" : "CLOSED",
        "frontRight" : "CLOSED",
        "backLeft" : "CLOSED",
        "backRight" : "CLOSED",
        "roof" : "UNSUPPORTED",
        "maintenanceHatch" : "UNSUPPORTED",
        "sunroof" : {
          "status" : "UNSUPPORTED",
          "positionInPercent" : null
        }
      },
      "parkingTime" : "28.01.2024 08:42:37",
      "overallOpenStatus" : "CLOSED",
      "chargingStatus" : "CHARGING_COMPLETED",
      "carModel" : "J1",
      "engineType" : "BEV",
      "chargingState" : "COMPLETED"
    }
    """
  end

  def capabilities do
    """
    {
      "displayParkingBrake" : true,
      "needsSPIN" : true,
      "hasRDK" : true,
      "hasDX1" : false,
      "engineType" : "BEV",
      "carModel" : "J1",
      "heatingCapabilities" : {
        "frontSeatHeatingAvailable" : true,
        "rearSeatHeatingAvailable" : true
      },
      "steeringWheelPosition" : "LEFT"
    }
    """
  end

  def maintenance do
    """
    {
      "data" : [ {
        "id" : "0003",
        "description" : {
          "shortName" : "Inspektion",
          "longName" : null,
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Service-Intervall",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "WarnID100" : "0",
          "modelId" : "0003",
          "modelState" : "active",
          "criticality" : "1",
          "WarnID99" : "0",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0005",
        "description" : {
          "shortName" : "Bremsbeläge",
          "longName" : "Wechsel des Bremsbelags",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Service Bremse",
          "odometerLastReset" : "23",
          "modelVisibilityState" : "visible",
          "modelId" : "0005",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T12:00:01",
          "source" : "Vehicle",
          "event" : "CYCLIC",
          "WarnID26" : "0"
        }
      }, {
        "id" : "0007",
        "description" : {
          "shortName" : "Bremsflüssigkeit",
          "longName" : "Wechsel der Bremsflüssigkeit",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Bremsfluessigkeit",
          "odometerLastReset" : "23",
          "modelVisibilityState" : "visible",
          "modelId" : "0007",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T12:00:01",
          "source" : "Vehicle",
          "event" : "CYCLIC",
          "WarnID1" : "0"
        }
      }, {
        "id" : "0008",
        "description" : {
          "shortName" : "RDK-Batterie (vorne links)",
          "longName" : "Wechsel der RDK-Batterie (vorne links)",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Reifendruckkontrolle VL",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "modelId" : "0008",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T19:56:32",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0009",
        "description" : {
          "shortName" : "RDK-Batterie (vorne rechts)",
          "longName" : "Wechsel der RDK-Batterie (vorne rechts)",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Reifendruckkontrolle VR",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "modelId" : "0009",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T19:56:32",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0010",
        "description" : {
          "shortName" : "RDK-Batterie (hinten links)",
          "longName" : "Wechsel der RDK-Batterie (hinten links)",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Reifendruckkontrolle HL",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "modelId" : "0010",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T19:56:32",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0011",
        "description" : {
          "shortName" : "RDK-Batterie (hinten rechts)",
          "longName" : "Wechsel der RDK-Batterie (hinten rechts)",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Reifendruckkontrolle HR",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "modelId" : "0011",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T19:56:32",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0012",
        "description" : {
          "shortName" : "Innenraumluftfilter",
          "longName" : "Wechsel des Innenraumluftfilters",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Innenraumluftfilter",
          "odometerLastReset" : "23",
          "modelVisibilityState" : "visible",
          "modelId" : "0012",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T12:00:01",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0017",
        "description" : {
          "shortName" : "Reifendichtmittel",
          "longName" : "Wechsel des Reifendichtmittels",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Reifen-Reparatur-Set",
          "odometerLastReset" : "23",
          "modelVisibilityState" : "visible",
          "modelId" : "0017",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T12:00:01",
          "source" : "Vehicle",
          "event" : "CYCLIC",
          "expirationDate" : "2025-12-01T12:00:00"
        }
      }, {
        "id" : "0034",
        "description" : {
          "shortName" : "Hauptuntersuchung",
          "longName" : "Hauptuntersuchung (HU)",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Hauptuntersuchung",
          "odometerLastReset" : "23",
          "modelVisibilityState" : "visible",
          "modelId" : "0034",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T12:00:01",
          "source" : "Vehicle",
          "event" : "CYCLIC",
          "expirationDate" : "2024-05-01T12:00:00"
        }
      }, {
        "id" : "0018",
        "description" : {
          "shortName" : "Wischerblätter",
          "longName" : "Wechsel der Wischerblätter",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "Wischerblaetter",
          "odometerLastReset" : "23",
          "modelVisibilityState" : "visible",
          "modelId" : "0018",
          "modelState" : "active",
          "criticality" : "1",
          "wipingCycleCounter" : "-1",
          "timestampLastReset" : "2022-05-11T12:00:01",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      }, {
        "id" : "0021",
        "description" : {
          "shortName" : "12V-Batterie",
          "longName" : "Wechsel der 12V-Batterie",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "WarnID477" : "0",
          "modelName" : "Batterie (12V)",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "WarnID452" : "0",
          "modelId" : "0021",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T19:56:32",
          "source" : "Vehicle",
          "event" : "CYCLIC",
          "WarnID294" : "0"
        }
      }, {
        "id" : "0037",
        "description" : {
          "shortName" : "On-Board DC-Lader",
          "longName" : "On-Board DC-Lader",
          "criticalityText" : "Zurzeit ist kein Service notwendig.",
          "notificationText" : null
        },
        "criticality" : 1,
        "remainingLifeTimeInDays" : null,
        "remainingLifeTimePercentage" : null,
        "remainingLifeTimeInKm" : null,
        "values" : {
          "modelName" : "HV_Booster",
          "odometerLastReset" : "0",
          "modelVisibilityState" : "visible",
          "modelId" : "0037",
          "modelState" : "active",
          "criticality" : "1",
          "timestampLastReset" : "2022-05-11T19:56:32",
          "source" : "Vehicle",
          "event" : "CYCLIC"
        }
      } ],
      "serviceAccess" : {
        "access" : true
      }
    }
    """
  end

  def emobility(mutator \\ nil) do
    """
    {
      "batteryChargeStatus" : {
        "plugState" : "CONNECTED",
        "lockState" : "LOCKED",
        "chargingState" : "COMPLETED",
        "chargingReason" : "TIMER4",
        "externalPowerSupplyState" : "STATION_CONNECTED",
        "ledColor" : "GREEN",
        "ledState" : "PERMANENT_ON",
        "chargingMode" : "OFF",
        "stateOfChargeInPercentage" : 80,
        "remainingChargeTimeUntil100PercentInMinutes" : 0,
        "remainingERange" : {
          "value" : 248,
          "unit" : "KILOMETERS",
          "originalValue" : 248,
          "originalUnit" : "KILOMETERS",
          "valueInKilometers" : 248,
          "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
          "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
        },
        "remainingCRange" : null,
        "chargingTargetDateTime" : "2024-01-17T19:55",
        "status" : null,
        "chargeRate" : {
          "value" : 0,
          "unit" : "KM_PER_MIN",
          "valueInKmPerHour" : 0,
          "unitTranslationKey" : "EM.COMMON.UNIT.KM_PER_MIN",
          "unitTranslationKeyV2" : "TC.UNIT.KM_PER_MIN"
        },
        "chargingPower" : 0,
        "chargingTargetDateTimeOplEnforced" : null,
        "chargingInDCMode" : false
      },
      "directCharge" : {
        "disabled" : false,
        "isActive" : false
      },
      #{emobility_direct_climatisation(mutator)}
      "timers" : [ {
        "timerID" : "1",
        "departureDateTime" : "2024-01-20T18:41:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "2",
        "departureDateTime" : "2024-01-20T22:15:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "3",
        "departureDateTime" : "2024-01-18T15:52:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "4",
        "departureDateTime" : "2024-01-18T17:15:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : true,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "5",
        "departureDateTime" : "2024-01-17T07:00:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "CYCLIC",
        "climatised" : false,
        "weekDays" : {
          "THURSDAY" : true,
          "SUNDAY" : true,
          "FRIDAY" : true,
          "TUESDAY" : true,
          "SATURDAY" : true,
          "WEDNESDAY" : true,
          "MONDAY" : true
        },
        "active" : true,
        "chargeOption" : true,
        "targetChargeLevel" : 80,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      } ],
      "climateTimer" : null,
      "chargingProfiles" : {
        "currentProfileId" : 5,
        "profiles" : [ {
          "profileId" : 4,
          "profileName" : "Allgemein",
          "profileActive" : true,
          "profileOptions" : {
            "autoPlugUnlockEnabled" : false,
            "energyCostOptimisationEnabled" : false,
            "energyMixOptimisationEnabled" : false,
            "powerLimitationEnabled" : false,
            "timeBasedEnabled" : false,
            "usePrivateCurrentEnabled" : true
          },
          "chargingOptions" : {
            "minimumChargeLevel" : 30,
            "targetChargeLevel" : 100,
            "smartChargingEnabled" : true,
            "preferredChargingEnabled" : false,
            "preferredChargingTimeStart" : "19:00",
            "preferredChargingTimeEnd" : "07:00"
          },
          "position" : null,
          "timerActionList" : {
            "timerAction" : [ 1, 2, 3, 4, 5 ]
          }
        }, {
          "profileId" : 5,
          "profileName" : "Home",
          "profileActive" : true,
          "profileOptions" : {
            "autoPlugUnlockEnabled" : false,
            "energyCostOptimisationEnabled" : false,
            "energyMixOptimisationEnabled" : false,
            "powerLimitationEnabled" : false,
            "timeBasedEnabled" : false,
            "usePrivateCurrentEnabled" : true
          },
          "chargingOptions" : {
            "minimumChargeLevel" : 30,
            "targetChargeLevel" : 100,
            "smartChargingEnabled" : false,
            "preferredChargingEnabled" : true,
            "preferredChargingTimeStart" : "19:00",
            "preferredChargingTimeEnd" : "07:00"
          },
          "position" : {
            "latitude" : 45.444444,
            "longitude" : -75.693889,
            "radius" : 250,
            "radiusUnit" : "noUnit"
          },
          "timerActionList" : {
            "timerAction" : [ 1, 2, 3, 4, 5 ]
          }
        } ]
      },
      "departureInformation" : null,
      "errorInfo" : [ ]
    }
    """
  end

  defp emobility_direct_climatisation(:null_climate) do
    """
    "directClimatisation" : {
      "climatisationState" : "UNKNOWN",
      "remainingClimatisationTime" : null,
      "targetTemperature" : null,
      "climatisationWithoutHVpower" : null,
      "heaterSource" : null
    },
    """
  end

  defp emobility_direct_climatisation(_) do
    """
    "directClimatisation" : {
      "climatisationState" : "OFF",
      "remainingClimatisationTime" : null,
      "targetTemperature" : "2930",
      "climatisationWithoutHVpower" : "false",
      "heaterSource" : "electric"
    },
    """
  end

  def emobility_US do
    """
    {
      "batteryChargeStatus" : {
        "plugState" : "CONNECTED",
        "lockState" : "LOCKED",
        "chargingState" : "COMPLETED",
        "chargingReason" : "TIMER4",
        "externalPowerSupplyState" : "STATION_CONNECTED",
        "ledColor" : "GREEN",
        "ledState" : "PERMANENT_ON",
        "chargingMode" : "OFF",
        "stateOfChargeInPercentage" : 80,
        "remainingChargeTimeUntil100PercentInMinutes" : 0,
        "remainingERange" : {
          "value" : 159.6924,
          "unit" : "MILES",
          "originalValue" : 257,
          "originalUnit" : "KILOMETERS",
          "valueInKilometers" : 257,
          "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
          "unitTranslationKeyV2" : "TC.UNIT.MILES"
        },
        "remainingCRange" : null,
        "chargingTargetDateTime" : "2024-01-28T03:10",
        "status" : null,
        "chargeRate" : {
          "value" : 0,
          "unit" : "MILES_PER_MIN",
          "valueInKmPerHour" : 0,
          "unitTranslationKey" : "EM.COMMON.UNIT.MILES_PER_MIN",
          "unitTranslationKeyV2" : "TC.UNIT.MILES_PER_MIN"
        },
        "chargingPower" : 0,
        "chargingTargetDateTimeOplEnforced" : null,
        "chargingInDCMode" : false
      },
      "directCharge" : {
        "disabled" : false,
        "isActive" : false
      },
      "directClimatisation" : {
        "climatisationState" : "OFF",
        "remainingClimatisationTime" : null,
        "targetTemperature" : "2930",
        "climatisationWithoutHVpower" : "true",
        "heaterSource" : "electric"
      },
      "timers" : [ {
        "timerID" : "1",
        "departureDateTime" : "2024-01-30T13:52:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "2",
        "departureDateTime" : "2024-01-30T15:10:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "3",
        "departureDateTime" : "2024-01-31T17:00:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "4",
        "departureDateTime" : "2024-01-31T14:19:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "SINGLE",
        "climatised" : true,
        "weekDays" : null,
        "active" : true,
        "chargeOption" : false,
        "targetChargeLevel" : 85,
        "climatisationTimer" : true,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      }, {
        "timerID" : "5",
        "departureDateTime" : "2024-01-28T07:00:00.000Z",
        "preferredChargingTimeEnabled" : false,
        "preferredChargingStartTime" : null,
        "preferredChargingEndTime" : null,
        "frequency" : "CYCLIC",
        "climatised" : false,
        "weekDays" : {
          "MONDAY" : true,
          "FRIDAY" : true,
          "WEDNESDAY" : true,
          "SUNDAY" : true,
          "THURSDAY" : true,
          "TUESDAY" : true,
          "SATURDAY" : true
        },
        "active" : true,
        "chargeOption" : true,
        "targetChargeLevel" : 80,
        "climatisationTimer" : false,
        "e3_CLIMATISATION_TIMER_ID" : "4"
      } ],
      "climateTimer" : null,
      "chargingProfiles" : {
        "currentProfileId" : 5,
        "profiles" : [ {
          "profileId" : 4,
          "profileName" : "Allgemein",
          "profileActive" : true,
          "profileOptions" : {
            "autoPlugUnlockEnabled" : false,
            "energyCostOptimisationEnabled" : false,
            "energyMixOptimisationEnabled" : false,
            "powerLimitationEnabled" : false,
            "timeBasedEnabled" : false,
            "usePrivateCurrentEnabled" : true
          },
          "chargingOptions" : {
            "minimumChargeLevel" : 30,
            "targetChargeLevel" : 100,
            "smartChargingEnabled" : true,
            "preferredChargingEnabled" : false,
            "preferredChargingTimeStart" : "19:00",
            "preferredChargingTimeEnd" : "07:00"
          },
          "position" : null,
          "timerActionList" : {
            "timerAction" : [ 1, 2, 3, 4, 5 ]
          }
        }, {
          "profileId" : 5,
          "profileName" : "Home",
          "profileActive" : true,
          "profileOptions" : {
            "autoPlugUnlockEnabled" : false,
            "energyCostOptimisationEnabled" : false,
            "energyMixOptimisationEnabled" : false,
            "powerLimitationEnabled" : false,
            "timeBasedEnabled" : false,
            "usePrivateCurrentEnabled" : true
          },
          "chargingOptions" : {
            "minimumChargeLevel" : 30,
            "targetChargeLevel" : 100,
            "smartChargingEnabled" : false,
            "preferredChargingEnabled" : true,
            "preferredChargingTimeStart" : "19:00",
            "preferredChargingTimeEnd" : "07:00"
          },
          "position" : {
            "latitude" : 45.444444,
            "longitude" : -75.693889,
            "radius" : 250,
            "radiusUnit" : "noUnit"
          },
          "timerActionList" : {
            "timerAction" : [ 1, 2, 3, 4, 5 ]
          }
        } ]
      },
      "departureInformation" : null,
      "errorInfo" : [ ]
    }
    """
  end

  def position do
    """
    {
      "carCoordinate" : {
        "geoCoordinateSystem" : "WGS84",
        "latitude" : 45.444444,
        "longitude" : -75.693889
      },
      "heading" : 90
    }
    """
  end

  # My actual trip history is huge (50+ trips, 3000+ lines),
  # plus the timing and distances might be too much personal info.
  # So I'm breaking the pattern here and dynamically generating this.
  def trips_short_term(count) do
    id = Enum.random(1_000_000_000..9_999_999_999)
    odo = 9001
    time = DateTime.utc_now()

    1..count
    |> Enum.map_reduce({id, odo, time}, fn _, {id, odo, time} ->
      speed = Enum.random(10..100)
      minutes = Enum.random(10..100)
      distance = (speed * minutes / 60) |> round()
      energy = Enum.random(200..500) / 10

      id = id - Enum.random(1..1_000_000)
      odo_end = odo
      odo_start = odo - distance

      secs_between = 3600..(86400 * 3) |> Enum.random()
      time = time |> DateTime.add(-secs_between, :second)
      time_str = time |> DateTime.to_iso8601()

      chunk =
        """
          "type" : "SHORT_TERM",
          "id" : #{id},
          "averageSpeed" : {
            "value" : #{speed},
            "unit" : "KMH",
            "valueInKmh" : #{speed},
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KMH",
            "unitTranslationKeyV2" : "TC.UNIT.KMH"
          },
          "averageFuelConsumption" : {
            "value" : 0,
            "unit" : "LITERS_PER_100_KM",
            "valueInLitersPer100Km" : 0,
            "unitTranslationKey" : "GRAY_SLICE_UNIT_LITERS_PER_100_KM",
            "unitTranslationKeyV2" : "TC.UNIT.LITERS_PER_100_KM"
          },
          "tripMileage" : {
            "value" : #{distance},
            "unit" : "KILOMETERS",
            "originalValue" : #{distance},
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : #{distance},
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "travelTime" : #{minutes},
          "startMileage" : {
            "value" : #{odo_start},
            "unit" : "KILOMETERS",
            "originalValue" : #{odo_start},
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : #{odo_start},
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "endMileage" : {
            "value" : #{odo_end},
            "unit" : "KILOMETERS",
            "originalValue" : #{odo_end},
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : #{odo_end},
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "timestamp" : "#{time_str}",
          "zeroEmissionDistance" : {
            "value" : #{distance},
            "unit" : "KILOMETERS",
            "originalValue" : #{distance},
            "originalUnit" : "KILOMETERS",
            "valueInKilometers" : #{distance},
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
            "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
          },
          "averageElectricEngineConsumption" : {
            "value" : #{energy},
            "unit" : "KWH_PER_100KM",
            "valueKwhPer100Km" : #{energy},
            "unitTranslationKey" : "GRAY_SLICE_UNIT_KWH_PER_100KM",
            "unitTranslationKeyV2" : "TC.UNIT.KWH_PER_100KM"
          }
        """

      {[chunk], {id, odo_start, time}}
    end)
    |> then(fn {chunks, _} ->
      [
        "[ {\n",
        chunks |> Enum.intersperse("}, {\n"),
        "} ]\n"
      ]
      |> IO.iodata_to_binary()
    end)
  end

  def trips_long_term do
    """
    [ {
      "type" : "LONG_TERM",
      "id" : 2627363506,
      "averageSpeed" : {
        "value" : 31,
        "unit" : "KMH",
        "valueInKmh" : 31,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KMH",
        "unitTranslationKeyV2" : "TC.UNIT.KMH"
      },
      "averageFuelConsumption" : {
        "value" : 0,
        "unit" : "LITERS_PER_100_KM",
        "valueInLitersPer100Km" : 0,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_LITERS_PER_100_KM",
        "unitTranslationKeyV2" : "TC.UNIT.LITERS_PER_100_KM"
      },
      "tripMileage" : {
        "value" : 1759,
        "unit" : "KILOMETERS",
        "originalValue" : 1759,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 1759,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "travelTime" : 3479,
      "startMileage" : {
        "value" : 7242,
        "unit" : "KILOMETERS",
        "originalValue" : 7242,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 7242,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "endMileage" : {
        "value" : 9001,
        "unit" : "KILOMETERS",
        "originalValue" : 9001,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 9001,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "timestamp" : "2024-01-01T01:02:03Z",
      "zeroEmissionDistance" : {
        "value" : 1759,
        "unit" : "KILOMETERS",
        "originalValue" : 1759,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 1759,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "averageElectricEngineConsumption" : {
        "value" : 32.7,
        "unit" : "KWH_PER_100KM",
        "valueKwhPer100Km" : 32.7,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KWH_PER_100KM",
        "unitTranslationKeyV2" : "TC.UNIT.KWH_PER_100KM"
      }
    }, {
      "type" : "LONG_TERM",
      "id" : 2586922833,
      "averageSpeed" : {
        "value" : 42,
        "unit" : "KMH",
        "valueInKmh" : 42,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KMH",
        "unitTranslationKeyV2" : "TC.UNIT.KMH"
      },
      "averageFuelConsumption" : {
        "value" : 0,
        "unit" : "LITERS_PER_100_KM",
        "valueInLitersPer100Km" : 0,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_LITERS_PER_100_KM",
        "unitTranslationKeyV2" : "TC.UNIT.LITERS_PER_100_KM"
      },
      "tripMileage" : {
        "value" : 7242,
        "unit" : "KILOMETERS",
        "originalValue" : 7242,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 7242,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "travelTime" : 10415,
      "startMileage" : {
        "value" : 0,
        "unit" : "KILOMETERS",
        "originalValue" : 0,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 0,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "endMileage" : {
        "value" : 7242,
        "unit" : "KILOMETERS",
        "originalValue" : 7242,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 7242,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "timestamp" : "2023-12-08T23:45:25Z",
      "zeroEmissionDistance" : {
        "value" : 7242,
        "unit" : "KILOMETERS",
        "originalValue" : 7242,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 7242,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KILOMETER",
        "unitTranslationKeyV2" : "TC.UNIT.KILOMETER"
      },
      "averageElectricEngineConsumption" : {
        "value" : 9.5,
        "unit" : "KWH_PER_100KM",
        "valueKwhPer100Km" : 9.5,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_KWH_PER_100KM",
        "unitTranslationKeyV2" : "TC.UNIT.KWH_PER_100KM"
      }
    } ]
    """
  end

  def trips_long_term_US do
    """
    [ {
      "type" : "LONG_TERM",
      "id" : 2140611149,
      "averageSpeed" : {
        "value" : 18.01976,
        "unit" : "MPH",
        "valueInKmh" : 28.99999,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MPH",
        "unitTranslationKeyV2" : "TC.UNIT.MPH"
      },
      "averageFuelConsumption" : {
        "value" : 0,
        "unit" : "MILES_PER_GALLON_US",
        "valueInLitersPer100Km" : 0,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES_PER_GALLON_US",
        "unitTranslationKeyV2" : "TC.UNIT.MILES_PER_GALLON_US"
      },
      "tripMileage" : {
        "value" : 1262.005,
        "unit" : "MILES",
        "originalValue" : 2031,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 2031,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "travelTime" : 4241,
      "startMileage" : {
        "value" : 4347.734,
        "unit" : "MILES",
        "originalValue" : 6997,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 6997,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "endMileage" : {
        "value" : 5610.36,
        "unit" : "MILES",
        "originalValue" : 9029,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 9029,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "timestamp" : "2024-02-01T22:20:07Z",
      "zeroEmissionDistance" : {
        "value" : 1262.626,
        "unit" : "MILES",
        "originalValue" : 2032,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 2032,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "averageElectricEngineConsumption" : {
        "value" : 1.877254,
        "unit" : "MILES_PER_KWH",
        "valueKwhPer100Km" : 33.10001,
        "unitTranslationKey" : "TC.UNIT.MILES_PER_KWH",
        "unitTranslationKeyV2" : "TC.UNIT.MILES_PER_KWH"
      }
    }, {
      "type" : "LONG_TERM",
      "id" : 2140211878,
      "averageSpeed" : {
        "value" : 25.47622,
        "unit" : "MPH",
        "valueInKmh" : 41,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MPH",
        "unitTranslationKeyV2" : "TC.UNIT.MPH"
      },
      "averageFuelConsumption" : {
        "value" : 0,
        "unit" : "MILES_PER_GALLON_US",
        "valueInLitersPer100Km" : 0,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES_PER_GALLON_US",
        "unitTranslationKeyV2" : "TC.UNIT.MILES_PER_GALLON_US"
      },
      "tripMileage" : {
        "value" : 4347.734,
        "unit" : "MILES",
        "originalValue" : 6997,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 6997,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "travelTime" : 10415,
      "startMileage" : {
        "value" : 0,
        "unit" : "MILES",
        "originalValue" : 0,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 0,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "endMileage" : {
        "value" : 4347.734,
        "unit" : "MILES",
        "originalValue" : 6997,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 6997,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "timestamp" : "2023-12-08T23:45:25Z",
      "zeroEmissionDistance" : {
        "value" : 4347.734,
        "unit" : "MILES",
        "originalValue" : 6997,
        "originalUnit" : "KILOMETERS",
        "valueInKilometers" : 6997,
        "unitTranslationKey" : "GRAY_SLICE_UNIT_MILES",
        "unitTranslationKeyV2" : "TC.UNIT.MILES"
      },
      "averageElectricEngineConsumption" : {
        "value" : 6.540749,
        "unit" : "MILES_PER_KWH",
        "valueKwhPer100Km" : 9.500001,
        "unitTranslationKey" : "TC.UNIT.MILES_PER_KWH",
        "unitTranslationKeyV2" : "TC.UNIT.MILES_PER_KWH"
      }
    } ]
    """
  end

  def unknown_502_error do
    """
    {
      "pcckErrorKey" : "GRAY_SLICE_ERROR_UNKNOWN_MSG",
      "pcckErrorMessage" : null,
      "pcckErrorCode" : null,
      "pcckIsBusinessError" : false
    }
    """
  end

  def service_access_502_error do
    """
    {
      "pccErrorCode" : "Source system: [SERVICE_ACCESS], message: [Getting Service Access Failed], error code: [null], translation key: [null], class=TechnicalException, http status: [null], http headers: [null], cause: [class java.util.concurrent.ExecutionException]"
    }
    """
  end
end
