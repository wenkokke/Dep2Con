{-# LANGUAGE FlexibleContexts #-}
module Language.Structure.Dependency.Parse (pTree) where


import Data.List (sort)
import Language.Structure.Dependency (Tree(..), Link(..), Label(..))
import Language.Word (Word (..))
import Language.Word.Parse (pWord)
import Text.ParserCombinators.UU ((<$>),pSome)
import Text.ParserCombinators.UU.BasicInstances (Parser)
import Text.ParserCombinators.UU.Idioms (iI,Ii (..))
import Text.ParserCombinators.UU.Utils (lexeme,pLetter)


pTree :: Parser Tree
pTree = flip depsToTree (Word "ROOT" 0) <$> pDeps
  where
    pRel  :: Parser Label
    pRel  = Label <$> pSome pLetter
    pDep  :: Parser (Label, Word, Word)
    pDep  = iI (,,) pRel '(' (lexeme pWord) ',' (lexeme pWord) ')' Ii
    pDeps :: Parser [(Label, Word, Word)]
    pDeps = pSome (lexeme pDep)

    depsToTree :: [(Label, Word, Word)] -> Word -> Tree
    depsToTree deps g = Node g (sort $ mkLink <$> getDeps g)
      where
        getDeps :: Word -> [(Label, Word, Word)]
        getDeps w = filter (\ (_, g, _) -> g == w) deps
        mkLink :: (Label, Word, Word) -> Link
        mkLink (r , _ , d) = Link r (depsToTree deps d)
