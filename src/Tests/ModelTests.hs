module Tests.ModelTests where

import Model
import Tests.Tests
import Control.Monad

import Test.HUnit hiding (State)

allTestsList :: [Test]
allTestsList = [tevTests, relTests]

allTests = concatTests allTestsList

-- Testing Evaluation

tev1 :: Test
tev1 = "Check evaluation works for truth " 
     ~: True ~=? satisfies (exampleModel1, (State (0, []))) (P (N a b))

tev2 :: Test
tev2 = "Check evaluation works for false " 
     ~: False ~=? satisfies (exampleModel1, (State (0, []))) (P (S b a))

tev3 :: Test
tev3 = "Check updates working"
     ~: True ~=? satisfies (updateModel, (State (0, [Call a b]))) (P (S b a))

tev4 :: Test
tev4 = "Check that updates to everyone being an expert work "
     ~: True ~=? satisfies (updateModel, (State (0, [Call a b]))) (allExperts updateModel)

tev5 :: Test
tev5 = "Check that impossible call updates can't evaluate to true"
     ~: False ~=? satisfies (updateModel, (State (0, [Call b a]))) (P (S b a))

tev6 :: Test 
tev6 = "Indeed, check that impossible calls don't produce an updated state"
     ~: False ~=? (State (0, [Call b a])) `elem` states updateModel

tev7 :: Test 
tev7 = "Check that possible calls do yield an updated state"
     ~: True ~=? (State (0, [Call a b])) `elem` states updateModel

-- We don't need Test n in front of the actual test
tevTests :: Test
tevTests = test [tev1, tev2, tev3, tev4, tev5, tev6, tev7]

exampleModel1 :: EpistM StateC GosProp
exampleModel1 = Mo 
    [State (0, [])]
    [a, b]
    [(State (0, []), [P (S a b), P (N a b)])]
    [(a, [[State (0, [])]]), (b, [[State (0, [])]])]
    [State (0, [])]
    (produceAllProps [a, b])

eventModel1 :: EventModel Call GosProp
eventModel1 = EvMo 
    [Call a b, Call b a] 
    [(a, [[Call a b], [Call b a]]), (b, [[Call a b], [Call b a]])] 
    anyCall 
    postUpdate

updateModel :: EpistM StateC GosProp
updateModel = update exampleModel1 eventModel1

-- Testing Relations

relTests :: Test
relTests = test [
            "Agent a cannot distinguish between any of the four worlds"
            ~: (a, [[State (0, [Call a b]), State (0, [Call b a]), State (1, [Call a b]), State (1, [Call b a])]])
            ~=? (showRel relUpdate !! 0),
            "Agent b can distinguish between all three world"
            ~: (b, [[State (0, [Call a b])], [State (0, [Call b a])], [State (1, [Call a b])], [State (1, [Call b a])]])
            ~=? (showRel relUpdate !! 1)
            ]

relModel :: EpistM StateC GosProp
relModel = Mo 
    [State (0, []), State (1, [])]
    [a, b]
    [(State (0, []), [P (N a b), P (N b a)]), (State (1, []), [P (N a b), P (N b a)])]
    [(a, [[State (0, []), State (1, [])]]), (b, [[State (0, [])], [State (1, [])]])]
    [State (0, [])]
    (produceAllProps [a, b])

relEvent :: EventModel Call GosProp
relEvent = EvMo
    [Call a b, Call b a]
    [(a, [[Call a b, Call b a]]), (b, [[Call a b], [Call b a]])]
    anyCall
    postUpdate

relUpdate :: EpistM StateC GosProp
relUpdate = update relModel relEvent

showRel :: EpistM st p -> [(Agent, Rel st)]
showRel (Mo _ _ _ r _ _) = r








