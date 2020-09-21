import Penguin

let input = """
let x = 82
var y = 41
print(x)
"""

// Create a "main" function to insert top-level instructions.
let main = Function(name: "name")
let block = main.createBlock()

// Configure the transpiler context so that it emits code in the function we've just created.
var context = TranspilerContext()
context.functions = [main]
context.block = block

// Transpile the input into Penguin IR.
Transpiler.parse(input, in: &context)

print(block.instructions)
