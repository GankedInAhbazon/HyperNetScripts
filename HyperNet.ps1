function Convert-ReadableNumber {
    param (
        [string]$value,
        [string]$fieldName
    )

    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing or empty input for '$fieldName'."
    }

    $trimmed = $value.Trim().ToLower()

    switch -Regex ($trimmed) {
        '^([\d.]+)b$' { return [double]$matches[1] * 1e9 }
        '^([\d.]+)m$' { return [double]$matches[1] * 1e6 }
        '^([\d.]+)k$' { return [double]$matches[1] * 1e3 }
        '^([\d.]+)$'  { return [double]$matches[1] }
        default {
            throw "❌ Invalid numeric input format for '$fieldName': '$value'"
        }
    }
}

function HyperNet {
    try {
        $HypernetListRaw = Read-Host "Hypernet List Price? (e.g., 1.5b)"
        $NumberOfNodesRaw = Read-Host "How many nodes for this hypernet? 8, 16, 48, or 512?"
        $HyperCorePriceRaw = Read-Host "What is the current price of HyperCores? (e.g., 300k)"
        $SelfBuyRaw = Read-Host "How many nodes will you buy?"
        $RebateRaw = Read-Host "How many nodes are you offering for a rebate?"
        $RBPercentRaw = Read-Host "At what percentage?"
        $ShipCostRaw = Read-Host "How much did you pay for the ship? (e.g., 150m)"
        $HoldInput = Read-Host "Hold or no hold? yes or no"

        Write-Host "`n--- INPUTS ---"
        Write-Host "Hypernet List Price: $HypernetListRaw"
        Write-Host "Node Count: $NumberOfNodesRaw"
        Write-Host "HyperCore Price: $HyperCorePriceRaw"
        Write-Host "SelfBuy: $SelfBuyRaw"
        Write-Host "Rebate Nodes: $RebateRaw"
        Write-Host "Rebate %: $RBPercentRaw"
        Write-Host "Ship Cost: $ShipCostRaw"
        Write-Host "Hold?: $HoldInput"
        Write-Host "--------------`n"

        # Convert inputs
        $HypernetList = Convert-ReadableNumber -value $HypernetListRaw -fieldName "Hypernet List Price"
        $NumberOfNodes = [double]$NumberOfNodesRaw.Trim()
        $HyperCoreMarketPrice = Convert-ReadableNumber -value $HyperCorePriceRaw -fieldName "HyperCore Market Price"
        $SelfBuy = [double]$SelfBuyRaw.Trim()
        $Rebate = [double]$RebateRaw.Trim()
        $RBPercentage = [double]$RBPercentRaw.Trim()
        $ShipCost = Convert-ReadableNumber -value $ShipCostRaw -fieldName "Ship Cost"
        $Hold = $HoldInput.Trim().ToLower() -eq "yes"

        # Calculations
        $NodePrice = $HypernetList / $NumberOfNodes
        $SelfBuyCost = $SelfBuy * $NodePrice
        $HyperCoreRatio = 12753734
        $NumberOfCores = $HypernetList / $HyperCoreRatio
        $HyperCoreCost = $NumberOfCores * $HyperCoreMarketPrice
        $HyperNetFee = $HypernetList * 0.05
        $RebatePayout = ($NodePrice * $Rebate) * ($RBPercentage / 100)

        # Profit calculations
        $TotalWithHoldAndRebate = $HypernetList - $HyperNetFee - $HyperCoreCost - $SelfBuyCost - $RebatePayout
        $TotalWithHoldNoRebate = $HypernetList - $HyperNetFee - $HyperCoreCost - $SelfBuyCost
        $TotalNoHold = $HypernetList - $HyperNetFee - $HyperCoreCost - $SelfBuyCost - $ShipCost

        $Format = {
            param ($amount)
            return "{0:N2}b" -f ([double]$amount / 1e9)
        }

        if (-not $Hold) {
            Write-Host "No hold: Profit is $( & $Format $TotalNoHold )"
        }
        elseif ($Rebate -eq 0 -or $RBPercentage -eq 0) {
            Write-Host "On hold with no rebate: Profit is $( & $Format $TotalWithHoldNoRebate )"
        }
        else {
            Write-Host "On hold with rebate: Profit is $( & $Format $TotalWithHoldAndRebate )"
        }

    } catch {
        Write-Error "HyperNet : ❌ $_"
    }
}

HyperNet
