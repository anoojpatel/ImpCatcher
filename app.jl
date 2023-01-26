module App # Needed for Genie to use loadapp()

using Genie.Renderer.Html, Stipple, StippleUI
using ImpCatcher
using Chess

const C = Chess
@reactive mutable struct Model <: ReactiveModel
  process::R{Bool} = false
  rollout::R{Bool} = false
  reset::R{Bool} = false
  output::R{String} = ""
  input::R{String} = ""
  boardstr::R{String} = repr(C.startboarddark())
  boardhtml::R{String} = repr(C.MIME.html(C.startboarddark(), highlight=C.visiblesquares(C.startboarddark(),C.moves(C.startboarddark()))))
  board::R{Board} = C.startboarddark()
end

function handlers(model)
  on(model.process) do _
    if (model.process[])
      model.output[] = model.input[]
      model.board[] = C.domove(model.board[!], model.input[!])
      model.boardstr[] = repr(model.board[!])
      model.boardhtml[] = repr(C.MIME.html(model.board[!], highlight=C.visiblesquares(model.board[!],C.moves(model.board[!]))))
      model.process[] = false
    end
  end
  on(model.reset) do _
    if (model.reset[])
      model.board[] = C.startboarddark()
      model.boardstr[] = repr(model.board[!])
      model.boardhtml[] = repr(C.MIME.html(model.board[!], highlight=C.visiblesquares(model.board[!],C.moves(model.board[!]))))
      model.reset[] = false
    end
  end
  on(model.rollout) do _
    if (model.rollout[])
      model.board[], _ = ImpCatcher.simulate_rollout(model.board[!], ImpCatcher.CESPF, 0)
      model.boardhtml[] = repr(C.MIME.html(model.board[!], highlight=C.visiblesquares(model.board[!],C.moves(model.board[!]))))
      model.rollout[] = false
    end

  end

  model
end

function landingpage_ui(model)
  page(model, class="container", style="text-align: center;", [
    img(src="/wizard_chess.webp", style="padding-top: 25px;")
    h1("Learn the Dark arts of Dark Chess Bots")
    h3("Interactive paper and implementation walk through to building a state of the dark chess bot")
    h4("with Deep RL concepts")
    p([
      a([
        input("Explore the paper",type="button", value="Explore the paper", class="button8", style="""
a.button8{
 display:inline-block;
 padding:0.2em 1.45em;
 margin:0.1em;
 border:0.15em solid #CCCCCC;
 box-sizing: border-box;
 text-decoration:none;
 font-family:'Segoe UI','Roboto',sans-serif;
 font-weight:400;
 color:#000000;
 background-color:#CCCCCC;
 text-align:center;
 position:relative;
}
a.button8:hover{
 border-color:#7a7a7a;
}
a.button8:active{
 background-color:#999999;
}
@media all and (max-width:30em){
 a.button8{
  display:block;
  margin:0.2em auto;
 }
}
          """)
      ],href="$(linkto(:get_interactive_paper))")
    ])
  ])
end

function ui(model)
  page(model, class="container", style ="margin-left:10px;", [
                                  h1("Building Dark Chess Engines for SOTA Performance")
                                  h3("By Anooj Patel")
      
      h5("An Example Dark Chess Game with a Greedy Rollout")
      p([
         "Input Move in UCI format (e.g \"d2d4\") == Move(SQ_D2, SQ_D4)"
        input("", @bind(:input), @on("keyup.enter", "process = true"))
      ])

      p([
        button("Action!", @click("process = true"))
      ])

      p([
        "Last Move Processed"
        pre("", @text(:output))
      ])
      p("Green highlights show what the current player can see")
      span(
       var"v-html" = "boardhtml" # magic to summon vue js
      )
      #p([
      #   model.boardhtml[!]
      #  ], @on("keyup.enter"," boardhtml = repr(C.MIME.html(model))")
      #p([
      #   pre("{{ boardstr }}")
      #])
      p([
         button("Reset Game",@click("reset = true"))
      ])
      "CESPF is a Capture / Escape, Stronger Piece First Heuristic when trying to roll out perfect information chess boards."
      p([
         button("CESPF Greedy Rollout", @click("rollout = true"))
      ])
      p([
         h4("Background")
        "Imperfect information games are games like Poker, or Uno, where information about some of the players' states are unknown."
        " Conversely, Chess happens to be a perfect information game. Everyone knows where everyone's pieces are on the board. There's no hidden information."
        " Dark Chess takes both these ideas and combines them, to make a really F**ing hard game to play, and even harder to model via an algorithm or machine learning problem. Not only are numerous actions you can take with your pieces,"
      " You also have to extrapolate an exponentially growing set of possible states that your opponent is in. The search space ends up being very very large and intractible for traditional imperfect info (zero-sum) algorithms like CFR."
      br()
      h4("Methods Learned")
      "In this interactive paper, we're going to explore the combination of two novel methods from Stephen McAleer, specifically Neural E(X)tensive-form Double Oracle, along with ESCHER to build a top Dark Chess Engine."
      "We also will explore ideas of Neural Replicator Dynamics and Follow the Regularized Leader to explore how we can optimize our Deep RL models to traverse policy gradients more effectively."
      ])
    ],
    @iif(:isready)
  )
end

route("/") do
  model = Model |> init |> handlers
  html(landingpage_ui(model), context = @__MODULE__)
end

route("/interactive_paper") do
  model = Model |> init |> handlers
  html(ui(model), context = @__MODULE__)
end

end # module
#Genie.isrunning(:webserver) || up()
