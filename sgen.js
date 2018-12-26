const fs = require('fs');
const AST = JSON.parse(fs.readFileSync('./output.json').toString());
let temp = 'A';
if (AST.constant_definition) {
    for (const cst of AST.constant_definition.constant_definition_body) {
        console.log(`(= ${cst.arguments[1]}   ${cst.arguments[0].name})`);
    }
}
if (AST.variable_definition) {
    for (const variable of AST.variable_definition.variable_definition_body) {
        console.log(`(= 0   ${variable.name.name})`);
    }
}

const getTempVariableName = () => {
    const v = temp;
    temp = String.fromCharCode(temp.codePointAt() + 1);
    return v;
}

const handleStmt = (stmt) => {
    let nowStmt = stmt;
    if (stmt.type === 'block_statement') {
        handleStmt(stmt.body.body);
    } else if (stmt.type === 'statement_list') {
        for (const s of stmt.body) {
            handleStmt(s);
        }
    } else {
        if (stmt.type === 'assignment_statement') {
            if (stmt.body.arguments[1].type === 'expression') {
                const resultVariableName = handleExpression(stmt.body.arguments[1]);
                console.log(`(= ${resultVariableName}   ${stmt.body.arguments[0].name})`)
            } else {
                console.log(`(= ${stmt.body.arguments[0].name}   ${stmt.body.arguments[1]})`)
            }
        }
    }
}

const handleExpression = (expression) => {
    if (expression.arguments[0].type === 'item') {
        const variableName = getTempVariableName();
        const item = expression.arguments[0];
        if (item.arguments.length === 1) {
            console.log(`(= ${printFactor(item.arguments[0])}   ${variableName})`);
        } else {
            console.log(`(${item.arguments[1]} ${printFactor(item.arguments[0])} ${printFactor(item.arguments[2])} ${variableName})`);
        }
        return variableName;
    } else {
        const variableName = getTempVariableName();
        const anotherVariableName = getTempVariableName();
        const returnVariableName = handleExpression(expression.arguments[0]);
        const item = expression.arguments[2];
        if (item.arguments.length === 1) {
            console.log(`(= ${printFactor(item.arguments[0])}   ${variableName})`);
        } else {
            console.log(`(${item.arguments[1]} ${printFactor(item.arguments[0])} ${printFactor(item.arguments[2])} ${variableName})`);
        }
        console.log(`(${expression.arguments[1]} ${returnVariableName} ${variableName} ${anotherVariableName})`);
        return anotherVariableName;
    }
}

const printFactor = (factor) => {
    if (!factor.arguments[0].type) {
        return factor.arguments[0];
    } else {
        return factor.arguments[0].name;
    }
}

if (AST.statement_list && AST.statement_list.body.length > 0) {
    for (const stmt of AST.statement_list.body) {
        handleStmt(stmt);
    }
}