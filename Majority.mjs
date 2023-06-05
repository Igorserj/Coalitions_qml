WorkerScript.onMessage = function (message) {

    function getCombinations(valuesArray, k) {
        var combinations = []
        var n = valuesArray.length

        function inner(start, combo) {
            if (combo.length === k) {
                combinations.push(combo)
                return
            }
            for (var i = start; i < n; i++) {
                inner(i + 1, combo.concat(valuesArray[i]))
            }
        }
        inner(0, [])
        return combinations
    }

    function indexesOf(arr, value) {
        let indexes = []
        for (var i = 0; i < arr.length; i++) {
            if (arr[i] === value)
                indexes.push(i)
        }
        return indexes
    }

    var names = message.names
    const p = message.p
    let sum = p.reduce(function (a, b) {
        return parseInt(a) + parseInt(b)
    })
    const majority = Math.round(sum / 2) + 1
    let coalitions = []
    let sums = []
    let winners = []
    let winnersQ = []
    let winnersQCrit = []

    for (var i = 2; i <= names.length; i++)
        coalitions.push(getCombinations(message.names, i))

    console.log(coalitions)
    for (i = 0; i < coalitions.length; i++) {
        for (var j = 0; j < coalitions[i].length; j++) {
            var summary = 0
            for (var k = 0; k < coalitions[i][j].length; k++) {
                summary += parseInt(p[names.indexOf(coalitions[i][j][k])])
            }
            sums.push(summary)
            if (summary >= majority) {
                winners.push(1)
            } else
                winners.push(0)
        }
    }
    winners = indexesOf(winners, 1)

    console.log(winners)
    let coalitions2 = []
    for (i = 0; i < coalitions.length; i++) {
        for (j = 0; j < coalitions[i].length; j++)
            coalitions2.push(coalitions[i][j])
    }

    console.log(coalitions2)
    for (i = 0; i < coalitions2.length; i++) {
        let buffer = []
        for (j = 0; j < names.length; j++) {
            buffer.push(0)
            i === 0 ? winnersQCrit.push(0) : {}
        }
        winnersQ.push(buffer)
    }

    for (i = 0; i < winners.length; i++) {
        for (j = 0; j < names.length; j++) {
            coalitions2[winners[i]].includes(names[j])
                    && sums[winners[i]] - parseInt(
                        p[j]) < majority ? [winnersQ[winners[i]][j] = 1, winnersQCrit[j] += 1] : {}
        }
    }

    console.log(winnersQCrit)
    console.log(winnersQ)
    coalitions2.unshift(" ")
    coalitions2.push(" ")
    WorkerScript.sendMessage({
                                 "coalitions": coalitions2,
                                 "winners": winners,
                                 "sum": sum,
                                 "sums": sums,
                                 "names": names,
                                 "majority": majority,
                                 "winnersQ": winnersQ,
                                 "winnersQCrit": winnersQCrit
                             })
}
