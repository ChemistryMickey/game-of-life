# Project Kuzco

## Requirements:
- Write Conrad's Game of Life
    - Shall include visualization
    - Shall include way of inputting starting conditions
    - Shall be written in {language} (I've never used Golang prior to this project)
- Learn EVERYTHING (viz, language, etc.) just using Meta's codellama:13b (NO GOOGLING except when sanity is at stake)

## Goals:
- Learn {language}
- Evaluate programmatic truthiness of solo LLM

## Go Conclusion:
Did I learn go? Kinda not really.
Missing out on a lot of the foundational stuff.
I'm not sure how memory works adn this wasn't complex enough to involve anything more sophisticated.

Not too bad but the LLM was really bad at returning functional code or suddenly throwing up way too much absurdly erroneous code.

That being said, I got some basic "error as values", JSON parsing/serialization, object orientation, input parsing, etc.
So all 'n all, not terrible.
Codellama:13b generally knew the right stdlib package to use to get the result I wanted even if the implementation it recommended was incorrect.
Codellama:13b + LSP was a much more powerful combination.

Could I code up something more complex in Golang + Codellama:13b? Yeah. 
The workflow doesn't feel great because it's back and forth with the terminal asking questions but it's not completely useless.
There's value there as a really bad instructor; the kind of instructor whose bad advice points you in "a" direction and upsets you enough to go do better. We've all had those teachers before.
This is that flavour of teacher concretized in weights.

So... Mission Accomplished...?

## Python Conclusion:
Eh. Python's my best language.
Codellama:13b didn't give any good advice here on the one question I asked though it might have just timed out such that my last question was without the context of the previous. 
Something to consider.

## Rust Conclusion:
Close but no cigar.
It knew that serde can be used to deserialize but codellama neither added the derived "Serialize" to the struct nor recommended adding serde to the Cargo.toml with the derive feature.

Also, the std::fs::read doesn't require a buffer input; that's an input required for std::io::stdin().read.

Not too shabby considering the proportion of Rust code probably available to codellama for training and the bias for Python.

## C++ Conclusion:
It knew about nlohmann for JSON parsing so it's not all bad!
Some of the snippets using nlohmann's JSON were also reasonably functional. Never quite what I asked but again, not too shabby.

It also knew about argparse and that's one library I hadn't used before.
Here I think the LLM really shines. It knew a corner of the ecosystem I didn't and even though the code it produced wasn't great, it still offered a good hook.

The question then becomes "is that hook better than a quick google?" to which I can say "probably?".
Especially as google moves towards using LLMs for their responses in their own right, these LLMs will become the curators of information in a way that StackOverflow was before.
I'm unsure that's a good thing (again, the code codellama produced was often not functional) but until the AI bubble pops, it's how it will be.

## Zig Conclusion:
**NOTE**: This technically broke the rules of the challenge because codellama didn't know zig at all. So I blustered through [the zig guide](https://zig.guide). 

Additionally, considering zig's still changing quite rapidly, I'm not sure it would produce functional code just because of version changes.
Async, for example, is no longer supported as of zig 0.11.

So the zig conclusion is "I just gotta get better at zig".
I still want to to do RAII which isn't ziggy.
Zig has some cool features but the only one that really stood out here was the `defer` key for care-free memory cleanup.
In a project of this size though, memory cleanup isn't strictly necessary. 
Still a nice feature though.

It's also nice that JSON is supported as part of zig's standard library!
A real hallmark of these modern languages is that they have excellent support for current standards (not a dig on C++, it came before JSON after all).

A final note on zig: As of 2024-08-03, the LSP in VSCode doesn't handle the unwrapping of nested containers correctly.
When unwrapping an `ArrayList` of `ArrayList(bool)`s, the first layer should produce an `ArrayList(bool)` but incorrectly inferred that to be the very base type `bool`. 
The LSP, however, wasn't complaining when I then went and continued unwrapping what it thought was just a bool such that it might just be a display bug.