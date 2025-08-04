# Fractional::Ai

## Problem Definition

Terminal Application that allows users to draw ascii-art lines and ascii-art canvas.

The end state is "user starts the application, they are shown an empty canvas, they are prompted where they want to draw the next line, and the canvas re-renders".

### Constraints

* Focus as much time on rendering output.
* Let's design some internal API that does that.
* Two end points define it, any angle.
* Start with horizontal and vertical.

## Usage 

The code will run in two ways: 

1. By asking user to input start and end of the line coordinates within the box
2. By injesting a file `config/config.json` which can cotain any number of lines, and additionally is able to assign a color to that line. We felt that having a non-interactive version was easier to test, and to test with.

