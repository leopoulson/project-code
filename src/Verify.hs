module Verify where

import MakeGraphs

import qualified Model
import ME
import Malvin.Gossip
import Malvin.Gossip.General


graph3 :: Graph
graph3 = exampleFromList [[0, 1], [1, 2], [2]]

graph4 :: Graph
graph4 = exampleFromList [[0, 2, 3], [0, 1], [2], [3]]

precon = lns

allKnowExperts :: Form
allKnowExperts = ForallAg (\ag -> K ag precon allExperts)

aKnowsExperts :: Form
aKnowsExperts = K 0 precon allExperts

dKnowsExperts :: Form
dKnowsExperts = K 3 precon allExperts

winningFormula :: Form
winningFormula = dKnowsExperts

t = eval (graph4, [(0, 2), (1, 0), (0, 3), (1, 3), (2, 3)]) winningFormula

verifyCalls :: Model.EpistM -> [Model.Event] -> Form ->  Bool
verifyCalls ep calls f = verifyE (exampleFromList $ graphToGattinger ep) (callsToGattinger calls) f

verifyAllExperts :: Model.EpistM -> [Model.Event] -> Bool
verifyAllExperts ep evs = verifyCalls ep evs allExperts

verifyWinning :: Model.EpistM -> [Model.Event] -> Bool
verifyWinning ep evs = verifyCalls ep evs winningFormula

verifyE :: Graph -> Sequence -> Form -> Bool
verifyE g sigma f = eval (g, sigma) f

findSequence :: (Model.EpistM, Maybe [ME.Character]) -> Sequence
findSequence (ep, _) = findNonEmpty (length $ Model.agents ep) (exampleFromList $ graphToGattinger ep)

findSequences :: [(Model.EpistM, Maybe [ME.Character])] -> [(Model.EpistM, Sequence)]
findSequences es = zip (map fst es) (map findSequence es)

-- of course, we need to fill the hole that null creates
-- we can use isSuccSequence, but it seems there's something he provides too 
verifyEmptyG :: Int -> Graph -> Bool
verifyEmptyG agents g = not $ any (isSuccSequence (g, [])) $ filter ((< (agents + 2)) . length) $ sequences precon (g, [])

findNonEmpty :: Int -> Graph -> Sequence
findNonEmpty agents g = head $ filter (isSuccSequence (g, [])) $ filter ((< (agents + 2)) . length) $ sequences precon (g, [])

verifyEmpty :: Model.EpistM -> Bool
verifyEmpty model = verifyEmptyG (length $ Model.agents model) . exampleFromList . graphToGattinger $ model

