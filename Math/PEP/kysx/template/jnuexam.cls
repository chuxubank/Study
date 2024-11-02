% -*- coding: utf-8 -*-
% ----------------------------------------------------------------------------
% Author:  Jianrui Lyu <tolvjr@163.com>
% Website: https://lvjr.bitbucket.io/jnuexam.html
% License: The LaTeX Project Public License 1.3
% ----------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jnuexam}[2020/12/20 v1.1 An exam class for Jinan University]

\newif\ifplain       \plainfalse      % 是否添加装订线和草稿纸
\newif\iftwoinone    \twoinonefalse   % 是否使用 A3 纸张
\newif\ifoneside     \onesidefalse    % 是否单面印刷试卷
\newif\ifresetnumber \resetnumbertrue % 是否对各题型小题分别编号
\newif\ifreverse     \reversefalse    % 是否逆序出题
\newif\ifanswer      \answertrue      % 是否显示答案
\newif\ifamsfonts    \amsfontsfalse   % 切换数学字体
\newif\ifsourcehan   \sourcehanfalse  % 切换思源字体
\newif\ifcellspace   \cellspacefalse  % 增加表格列间距
\newif\ifmedmath     \medmathfalse    % 切换公式尺寸

\DeclareOption{plain}{\plaintrue}
\DeclareOption{a3paper}{\twoinonetrue}
\DeclareOption{a3input}{\twoinonetrue\plaintrue}
\DeclareOption{oneside}{\onesidetrue}
\DeclareOption{reverse}{\reversetrue}
\DeclareOption{noanswer}{\answerfalse}
\DeclareOption{amsfonts}{\amsfontstrue}
\DeclareOption{sourcehan}{\sourcehantrue}
\DeclareOption{medmath}{\cellspacetrue\medmathtrue}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexart}} %其它选项

\ProcessOptions %不可省略

% 四号    小四号    五号      小五号
% 14bp    12bp      10.5bp    9bp
% 实际上，在旧版本 ctex 中只能用 cs4size 和 c5size 选项
% 而新版本 ctex 中，可以利用 zihao 选项指定各种中文字号
\PassOptionsToPackage{CJKnumber}{xeCJK}
\LoadClass[cs4size,UTF8,noindent]{ctexart}

% 在旧版本 xeCJK 中，必须用 CJKnumber 选项载入 CJKnumb 包，后面才载入会报错
% 但在新版本 xeCJK 中 CJKnumber 选项已经被废弃，需要在后面自行载入它
% 在 xeCJK 中已经禁止载入 CJK，但是在新版本 ctex 宏包中却失效了
% 我们假装 CJK 已经载入，再载入 CJKnumb，避免出现 \CJKglue 重复定义的问题
% 注意用 PDFLaTeX 编译时需要用到 CJK，所以只在未定义时才作修改
\ifdefined\else
  \@namedef{ver@CJK.sty}{}
  %\@namedef{opt@CJK.sty}{}
\fi
\RequirePackage{CJKnumb}

% 新版本 xeCJK 已经废弃并禁用 CJKfntef，改用 xeCJKfntef 取代，我们需要载入后者
% 注意要保证能在较旧的 TeX 系统中编译，我们只能用 \ifXeTeX 而不能用 \ifxetex
% 因为旧版本 iftex 宏包只有 \ifXeTeX 命令，而 ifxetex 宏包才有 \ifxetex 命令
% 在 2019 年 10 月，LaTeX 开发团队接管了 iftex 宏包，新版本同时提供这两个命令
\RequirePackage{CJKfntef}
\RequirePackage{iftex}
\ifXeTeX\@ifpackagelater{xeCJK}{2020/02/10}{\RequirePackage{xeCJKfntef}}{}\fi

\iftwoinone
  \RequirePackage[a3paper,landscape,twocolumn,columnsep=60mm,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
\else
  \RequirePackage[a4paper,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
\fi

\RequirePackage{amsmath}
\RequirePackage{array}
\RequirePackage{calc}
\RequirePackage{comment}
\RequirePackage[inline]{enumitem}
\RequirePackage{environ}
\RequirePackage{etoolbox}
\RequirePackage{fancyhdr}
\RequirePackage{zref-user,zref-lastpage}
\RequirePackage{tabularx}
\RequirePackage{xcolor}
\RequirePackage{xkeyval}

\ifplain
  \allowdisplaybreaks[4]
\fi

\ifamsfonts
  \RequirePackage{amssymb}
\else
  \RequirePackage[utopia]{mathdesign} % charter, utopia
  \renewcommand\bfdefault{bx}
  \let\oldoiint\oiint\renewcommand{\oiint}{\oldoiint\nolimits}
  \DeclareTextCommandDefault{\nobreakspace}{\leavevmode\nobreak\ }
\fi

\newcolumntype{Y}{>{\centering\arraybackslash}X}
\newcolumntype{n}[1]{>{\centering\arraybackslash}m{#1}}

\setlength{\parindent}{0em}
\setlength{\lineskiplimit}{4pt}
\setlength{\lineskip}{4pt}

%% ---------------------------------------------------------------------------
%% 装订线命令 \addbindingline
%% 草稿纸命令 \addscratchpaper
%% 这两个命令需要编译两次才能得到正确结果
%% ---------------------------------------------------------------------------

\newcommand{\setexam}[1]{\setkeys{jnuexam@setup}{#1}}

\ifplain\else
  \RequirePackage{tikz}
  \RequirePackage{everypage}
\fi

\newcommand{\bindinglineleft}{
  \path (current page.north west) +(25mm,-25mm) coordinate (a1);
  \path (current page.south west) +(25mm,25mm)  coordinate (a2);
  \draw[dashed] (a1) -- node[left=1mm,text width=1em,inner sep=0pt]{\1{线}\0\1{订}\0\1{装}} (a2);
}

\newcommand{\bindinglineright}{
  \path (current page.north east) +(-25mm,-25mm) coordinate (b1);
  \path (current page.south east) +(-25mm,25mm)  coordinate (b2);
  \draw[dashed] (b1) -- node[right=1mm,text width=1em,inner sep=0pt]{\2{装}\0\2{订}\0\2{线}} (b2);
}

\newcommand{\bindinglineone}{%
\def\0{\\[70mm]}\def\1{\rotatebox{90}}\def\2{\rotatebox{-90}}%
\begin{tikzpicture}[remember picture,overlay,very thick]
  \ifnumodd{\value{page}}{\bindinglineleft}{\bindinglineright}
\end{tikzpicture}}

\newcommand{\bindinglinetwo}{%
\def\0{\\[70mm]}\def\1{\rotatebox{90}}\def\2{\rotatebox{-90}}%
\begin{tikzpicture}[remember picture,overlay,very thick]
  \bindinglineleft\bindinglineright
\end{tikzpicture}}

\iftwoinone
  \let\bindingline=\bindinglinetwo
\else
  \let\bindingline=\bindinglineone
\fi

\define@key{jnuexam@setup}{binding}[2]{\def\zhuangdingxian{#1}}

\newcommand{\addbindingline}{%
  \ifcase\zhuangdingxian % 0
  \or % 1
    \ifbool{answer}{}{\bindingline}%
  \or % 2
    \bindingline
  \fi
}

\ifplain\else
  \AddEverypageHook{\addbindingline}
\fi

\newcommand{\scratchpaperone}{%
\begin{tikzpicture}[remember picture,overlay,font=\sffamily\fontsize{120pt}{120pt}\selectfont]
  \node[text=lightgray!40,text width=120pt] at (current page.center) {草\\ 稿\\ 纸};
\end{tikzpicture}}

\newcommand{\scratchpapertwo}{%
\begin{tikzpicture}[remember picture,overlay,font=\sffamily\fontsize{180pt}{180pt}\selectfont]
  \node[text=lightgray!40] at (current page.center) {草\quad 稿\quad 纸};
\end{tikzpicture}}

\define@key{jnuexam@setup}{scratch}[1]{\def\caogaozhi{#1}}

\newcounter{my@empty@page}   % 空白页数
\newcounter{my@scratch@page} % 草稿页数
\newcounter{my@extra@page}   % 空白页数+草稿页数

% 添加空白页，使得草稿纸前页数在单面印刷时为偶数，双面印刷时为4的倍数
% 添加草稿纸，页数在单面印刷时等于设置值的两倍，双面印刷时等于设置值的4倍
\newcommand{\doscratchpaperone}{%
  \clearpage\pagestyle{empty}\let\addbindingline=\relax
  \ifnumgreater{\caogaozhi}{0}{%
    \ifbool{oneside}{%
      \ifnumodd{\value{page}}%
        {\setcounter{my@empty@page}{0}}%
        {\setcounter{my@empty@page}{1}}%
      \setcounter{my@scratch@page}{\caogaozhi*2}%
    }{%
      \setcounter{my@empty@page}{(\value{page}+2)/4*4+1-\value{page}}%
      \setcounter{my@scratch@page}{\caogaozhi*4}%
    }%
    \my@add@extra@page
  }{}%
}

% 注意在 twocolumn 文档中，\newpage 到下一栏，\clearpage 到下一页
% 另外注意第一行的 \clearpage 等不能移动到 \my@add@extra@page 命令里
% 因为 \clearpage 后本页已经结束，page 表示的是下一页的页码
\newcommand{\doscratchpapertwo}{%
  \clearpage\pagestyle{empty}\let\addbindingline=\relax
  \ifnumgreater{\caogaozhi}{0}{%
    \ifbool{oneside}{%
      \setcounter{my@empty@page}{0}%
      \setcounter{my@scratch@page}{\caogaozhi}%
    }{%
      \setcounter{my@empty@page}{(\value{page}/2)-(\value{page}/2)/2*2}%
      \setcounter{my@scratch@page}{\caogaozhi*2}%
    }%
    \my@add@extra@page
  }{}%
}

\newcommand{\my@add@extra@page}{%
  \setcounter{my@extra@page}{\value{my@empty@page}+\value{my@scratch@page}}%
  \whileboolexpr{
    test{\ifnumgreater{\value{my@empty@page}}{0}}
  }{%
    \addtocounter{my@empty@page}{-1}%
    \leavevmode\clearpage
  }%
  \whileboolexpr{
    test{\ifnumgreater{\value{my@scratch@page}}{0}}
  }{%
    \addtocounter{my@scratch@page}{-1}%
    \leavevmode\scratchpaper\clearpage
  }%
  \addtocounter{page}{-\value{my@extra@page}}%
}

\iftwoinone
  \let\scratchpaper=\scratchpapertwo
  \let\doscratchpaper=\doscratchpapertwo
\else
  \let\scratchpaper=\scratchpaperone
  \let\doscratchpaper=\doscratchpaperone
\fi

% 在旧版本 ctex 宏包中不能用 \AtEndDocument 添加含中文的内容，即不能用 \appto 而要用 \preto
\newcommand{\addscratchpaper}{%
  \preto{\@enddocumenthook}{\doscratchpaper}%
}

\ifplain\else\ifanswer\else
  \addscratchpaper
\fi\fi

\iftwoinone
  \RequirePackage{pdfpages}
  % 新版本 pdfpages 将 \includepdf 放在文档开头时会有命令未定义的错误
  % 见 https://tex.stackexchange.com/questions/352007/ieeetran-and-pdfpages
  % 另外从 LaTeX release 2018 开始 \@ifundefined 不再将未定义命令定义为 \relax
  % 见 https://www.latex-project.org/news/latex2e-news/ltnews28.pdf
  \@ifundefined{@setmarks}{\let\@setmarks\relax}{}
\fi

%% ---------------------------------------------------------------------------
%% 试卷表头命令 \makehead
%% ---------------------------------------------------------------------------

\newcommand{\niandu}{2016-2017}
\newcommand{\xueqi}{2}
\newcommand{\kecheng}{数学课程}
\newcommand{\zhuanye}{}  % 专业学分
\newcommand{\jiaoshi}{吕荐瑞}
\newcommand{\shijian}{}  % 考试日期
\newcommand{\bixiu}{1}   % 1 为必修，0 为选修
\newcommand{\bijuan}{1}  % 1 为闭卷，0 为开卷
\newcommand{\shijuan}{A} % A 或 B 或 C 卷
\newcommand{\neizhao}{1} % 1 打勾，0 不勾
\newcommand{\waizhao}{1} % 1 打勾，0 不勾

\newcommand{\underspace}[1]{\kern0pt\underline{\hspace{#1}}\kern0pt\relax}
\newcommand{\underbox}[2]{\kern0pt\underline{\makebox[#1]{#2}}\kern0pt\relax}
\newcommand{\underparbox}[2]{\kern0pt\underline{\parbox[b]{#1}{#2}}\kern0pt\relax}

\newcommand{\ischeck}[1]{\ifnum#1>0\,$\checkmark$\,\else\quad\fi}
\newcommand{\isquad}[1]{\ifnum#1=0\,$\checkmark$\,\else\quad\fi}

\newcommand\my@temp@a{A}
\newcommand\my@temp@c{C}
\newcommand\my@empty{}

\newcommand{\head@table@a}{%
  \begin{tabular}{l}
    \underbox{11\ccwd}{\niandu}学年度第\underbox{5.5\ccwd}{\xueqi}学期 \\
    课程名称：\underbox{17.5\ccwd}{\kecheng\ifx\zhuanye\my@empty\else\kern0pt(\zhuanye)\fi} \\
    授课教师：\underparbox{17.5\ccwd}{\centering\rule{0pt}{3ex}\jiaoshi} \\
    考试时间：\underbox{17.5\ccwd}{\shijian} \\
  \end{tabular}
}

\newcommand{\head@table@b}{%
  \renewcommand{\arraystretch}{1}%
  \begin{tabular}{l}
    \textbf{课程类别} \\ 必修~[\ischeck{\bixiu}]\quad 选修~[\isquad{\bixiu}] \\
    \hline
    \textbf{考试方式} \\ 开卷~[\isquad{\bijuan}]\quad 闭卷~[\ischeck{\bijuan}] \\
    \hline
    \textbf{试卷类别}~(\,A, B, C\,)\\\relax [\,\shijuan\,]\hfill 共~\zpageref{LastPage}~页
  \end{tabular}
}

\newcommand{\head@table@c}{%
  \begin{tabular}{l}
    \underspace{10\ccwd}学院\underspace{8\ccwd}专业\underspace{7.5\ccwd}班\kern0pt(\kern0pt{}级\kern0pt) \\[1em]
    姓名\underspace{8\ccwd}学号\underspace{10\ccwd}\hfill
    \bfseries 内招~[\ischeck{\neizhao}]~~外招~[\ischeck{\waizhao}] %\\[0.8em]
  \end{tabular}
}

\newcommand{\makehead}{
  \thispagestyle{plain}
  \centerline{\LARGE\bfseries 暨\quad 南\quad 大\quad 学\quad 考\quad 试\quad 试\quad 卷}
  \vspace{2em}%
  \ifreverse
    \ifx\shijuan\my@temp@a\renewcommand{\shijuan}{B}\fi
    \ifx\shijuan\my@temp@c\renewcommand{\shijuan}{D}\fi
  \fi
  \noindent
  \begin{tabularx}{\linewidth}{|@{}X@{}|}
    \hline\renewcommand{\arraystretch}{1.5}%
    {\begin{tabularx}{\linewidth}{@{}>{\bfseries}l@{}|@{}X@{}|@{}l@{}}
      \begin{tabular}{l}教\\ 师\\ 填\\ 写\end{tabular} & \head@table@a & \head@table@b
    \end{tabularx}}\\
    \hline\renewcommand{\arraystretch}{0.9}%
    {\begin{tabularx}{\linewidth}{@{}>{\bfseries}l@{}|@{}X@{}}
      \begin{tabular}{l}考\\ 生\\ 填\\ 写\end{tabular} & \head@table@c
    \end{tabularx}}\\
    \hline
  \end{tabularx}
  \par\vspace{1em}
  \noindent\begin{tabularx}{\linewidth}{|*{8}{Y|}}
    \hline
    \textbf{题\quad 号} & 一 & 二 & 三 & 四 & 五 & 六 & 总分\\
    \hline
    \textbf{得\quad 分} &  &  &  &  &  &  & \\
    \hline
    \textbf{评阅人} &  &  &  &  &  &  & \\
    \hline
  \end{tabularx}
}

%% ---------------------------------------------------------------------------
%% 页眉页脚设定
%% ---------------------------------------------------------------------------

\newcommand{\my@columnbox}[1]{\makebox[\columnwidth]{#1}}
\newcommand{\my@headleft}{\hspace{-0.3em}《\kecheng》\kern-0.3em 试卷\,\shijuan}
\newcommand{\my@headright}{姓名\hspace{6em}学号\hspace{6em}}
\newcommand{\my@headtext}{\my@headleft\hfill \my@headright}
\newcommand{\my@foottext}{第~\thepage~页\quad 共~\zpageref{LastPage}~页}

% fancy page style
\fancyhf{} % 清空页眉页脚
\iftwoinone
  \renewcommand{\headrulewidth}{0pt}%
  \lhead{\small\underline{\my@columnbox{\my@headtext}\strut}}
  \rhead{\small\underline{\my@columnbox{\my@headtext}\strut}}
  \lfoot{\small\my@columnbox{\my@foottext}}
  \rfoot{\small\my@columnbox{\stepcounter{page}\my@foottext}}
\else
  \lhead{\small\my@headleft}
  \rhead{\small\my@headright}
  \cfoot{\small\my@foottext}
\fi

% plain page style
\fancypagestyle{plain}{
  \renewcommand{\headrulewidth}{0pt}%
  \fancyhf{}
  \iftwoinone
    \rhead{\small\underline{\my@columnbox{\my@headtext\strut}}}
    \lfoot{\small\my@columnbox{\my@foottext}}
    \rfoot{\small\my@columnbox{\stepcounter{page}\my@foottext}}
  \else
    \cfoot{\small\my@foottext}
  \fi
}

\ifplain
  \pagestyle{plain}
\else
  \pagestyle{fancy}
\fi

%% ---------------------------------------------------------------------------
%% 题型命令 \makepart
%% 附录命令 \makedata
%% 题目环境 problem
%% 解答环境 solution
%% 逆序选项 reverse
%% ---------------------------------------------------------------------------

\newif\ifonlyoneproblem \onlyoneproblemfalse % 此部分仅有一道题时不显示题目编号
\xdef\allproblems{}
\xdef\lastproblem{}
\newcounter{problem}        % 当前题型的小题编号
\newcounter{problemreal}    % 实际显示的小题编号，在各题型小题统一编号时使用
\newcounter{totalproblems}  % 之前各题型小题总数，在各题型小题统一编号时使用
\newcommand{\solutionname}{解}
\newcounter{choice} % 后面选择题的 abcd 环境要用到
\newcommand{\hangtext}{}
\newlength{\hanglength}
\colorlet{part number}{black}
\colorlet{problem number}{blue!80!black}
\colorlet{solution name}{blue!80!black}

\newcommand{\printproblems}{\ifreverse\lastproblem\allproblems\fi\xdef\allproblems{}\xdef\lastproblem{}}

\newcommand{\makepart}[2]{%
  \printproblems
  \setcounter{totalproblems}{\value{totalproblems}+\value{problem}}%
  \setcounter{problem}{0}%
  \stepcounter{section}%
  \vspace{1em}%
  \noindent\textbf{\textcolor{part number}{\Chinese{section}}、#1}（#2）%
  \par\nopagebreak
  \if\relax\detokenize{#1}\relax % #1 is empty
    \onlyoneproblemtrue
  \else
    \onlyoneproblemfalse
    \vspace{1em}%
  \fi
  %其中设定了\@nobreaktrue，保证在列表前也不分页，详情见 source2e
  \@afterheading
}

\newcommand{\makedata}[1]{%
  \printproblems\my@stop@reverse
  \centerline{\textbf{附录}\quad #1}\smallskip
}

\preto{\@enddocumenthook}{\printproblems\my@stop@reverse}

\newcommand\ignorepars{\@ifnextchar\par{\expandafter\ignorepars\@gobble}{}}

% 局部定义，仅在当前题目内有效
\define@key{jnuexam@problem}{points}[-1]{\def\my@problem@points{#1}}

\newcommand{\problempointstext}[1]{（#1 分）}

\newcommand{\execute@problem@keys}[1]{%
  \setkeys{jnuexam@problem}{#1}%
  \ifdefvoid{\my@problem@points}{}{\problempointstext{\my@problem@points}}%
}

\newenvironment{problemreal}[1][]{%
  \stepcounter{problem}\setcounter{choice}{0}%
  \ifresetnumber
    \ifonlyoneproblem
      \renewcommand{\hangtext}{\qquad}%
    \else
      \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{problem number}{\arabic{problem}}.}}\;\,}%
    \fi
  \else
    \setcounter{problemreal}{\value{totalproblems}+\value{problem}}%
    \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{problem number}{\arabic{problemreal}}.}}\;\,}%
  \fi
  \settowidth{\hanglength}{\hangtext}%
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]\execute@problem@keys{#1}%
}{\enddescription}
\newenvironment{solutionreal}{%
  \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{solution name}{\solutionname}.}}\;\,}%
  \settowidth{\hanglength}{\hangtext}%
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]
}{\enddescription}

\let \oldnewpage   = \newpage
\let \oldvfill     = \vfill
\let \oldsmallskip = \smallskip
\let \oldmedskip   = \medskip
\let \oldbigskip   = \bigskip

\ifreverse
  \NewEnviron{problem}{%
    \xdef\allproblems{%
      \unexpanded\expandafter{\lastproblem}%
      \unexpanded\expandafter{\allproblems}%
    }%
    \xdef\lastproblem{%
      \unexpanded{\begin{problemreal}}%
      \unexpanded\expandafter{\BODY}%
      \unexpanded{\end{problemreal}}%
    }%
  }
  \NewEnviron{solution}{%
    \xdef\lastproblem{%
      \unexpanded\expandafter{\lastproblem}%
      \unexpanded{\begin{solutionreal}}%
      \unexpanded\expandafter{\BODY}%
      \unexpanded{\end{solutionreal}}%
    }%
  }
  \renewcommand{\newpage}{\xdef\lastproblem{\noexpand\oldnewpage\unexpanded\expandafter{\lastproblem}}}
  \renewcommand{\vfill}{\xdef\lastproblem{\unexpanded\expandafter{\lastproblem\oldvfill}}}
  \renewcommand{\smallskip}{\xdef\lastproblem{\unexpanded\expandafter{\lastproblem\oldsmallskip}}}
  \renewcommand{\medskip}{\xdef\lastproblem{\unexpanded\expandafter{\lastproblem\oldmedskip}}}
  \renewcommand{\bigskip}{\xdef\lastproblem{\unexpanded\expandafter{\lastproblem\oldbigskip}}}
  \let \newpagea = \relax
  \let \newpageb = \newpage
\else
  \newenvironment{problem}[1][]{\problemreal[#1]}{\endproblemreal}
  %\newenvironment{solution}{\solutionreal}{\endsolutionreal}
  \NewEnviron{solution}{\begin{solutionreal}\BODY\end{solutionreal}}
  \let \newpagea = \newpage
  \let \newpageb = \relax
\fi

\newcommand{\my@stop@reverse}{%
  \ifreverse
    \renewenvironment{problem}{\problemreal}{\endproblemreal}%
    \renewenvironment{solution}{\solutionreal}{\endsolutionreal}%
    \let \newpage   = \oldnewpage
    \let \vfill     = \oldvfill
    \let \smallskip = \oldsmallskip
    \let \medskip   = \oldmedskip
    \let \bigskip   = \oldbigskip
  \fi
}

\def\CommentCutFile{\jobname.cut}

\AtBeginDocument{%
  \ifanswer\else
    \excludecomment{solution}
  \fi
}

%% ---------------------------------------------------------------------------
%% 答题栏命令 \answertable
%% ---------------------------------------------------------------------------

\gdef\answer@lines@temp{}%
\newcommand{\answer@lines@add}[1]{%
  \xdef\answer@lines@temp{\answer@lines@temp#1}%
}

\newrobustcmd{\answer@number@hided}[1]{小题} % 在 PDFLaTeX 中需要保护中文
\newrobustcmd{\answer@cell@strut}[1]{\parbox[c][#1][c]{2em}{\hbox{答案}}}

\newcounter{answer@col}
\newcounter{answer@row}
\newcounter{answer@total}

\newcommand{\answer@lines}[3]{%
  % #1 答题栏各栏指定高度
  % #2 答题栏总共答案个数
  % #3 答题栏每行答案个数
  \setcounter{answer@row}{(#2-1)/#3+1}% 除法向下取整，改为向上取整
  \begingroup
  \let\hline=\relax  \let\\=\relax % 禁止展开
  \gdef\answer@lines@temp{}%
  \setcounter{answer@total}{1}%
  \whileboolexpr{
      test{\ifnumgreater{\value{answer@row}}{0}}
  }{%
      \addtocounter{answer@row}{-1}%
      \answer@lines@add{\answer@number@hided}%
      \setcounter{answer@col}{1}%
      \unlessboolexpr{%
          test{\ifnumgreater{\value{answer@col}}{#3}}%
      }{%
          \answer@lines@add{&}%
          \ifnumgreater{\value{answer@total}}{#2}{}{%
            \answer@lines@add{\arabic{answer@total}}%
          }%
          \stepcounter{answer@col}%
          \stepcounter{answer@total}%
      }%
      \answer@lines@add{\\ \hline \answer@cell@strut{#1}}%
      \setcounter{answer@col}{1}%
      \unlessboolexpr{
          test{\ifnumgreater{\value{answer@col}}{#3}}
      }{%
          \answer@lines@add{&}%
          \stepcounter{answer@col}%
      }%
      \answer@lines@add{\\ \hline}%
  }%
  \endgroup
  \answer@lines@temp
}

\newcommand{\answertable}[3][1em]{%
  答题须知：本题答案必须写在如下表格中，否则不给分．\par
  \begin{tabularx}{\linewidth}{|c|*{#3}{Y|}}
    \hline
    \answer@lines{#1}{#2}{#3}
  \end{tabularx}%
  \par\vspace{0.8em}%
}

%% ---------------------------------------------------------------------------
%% 答案切换命令 \answer
%% 判断命令 \tickin 和 \tickout
%% 填空命令 \fillin 和 \fillout
%% 选择命令 \pickin 和 \pickout
%% ---------------------------------------------------------------------------

\newcommand{\answer}[1]{\ifanswer#1\else\phantom{#1}\fi}

\newcommand*{\cdotfill}{\leavevmode\xleaders\hbox to 0.5em{\hss$\cdot$\hss}\hfill\kern0pt\relax}

\newcommand*{\tick@box}[1]{[\makebox[1.5em]{\color{blue}\answer{#1}}]}
\newcommand*{\tick@text@t}{$\checkmark$}
\newcommand*{\tick@text@f}{{\large$\times$}}
\newcommand*{\tick@text@T}{\sffamily T}
\newcommand*{\tick@text@F}{\sffamily F}
\newcommand*{\tickin}[1]{\tick@box{\csname tick@text@#1\endcsname}}
\newcommand*{\tickout}[1]{\unskip\nobreak\cdotfill\tick@box{\csname tick@text@#1\endcsname}}
% 过时命令，不要再使用
\newcommand*{\true}{\tickout{t}}
\newcommand*{\false}{\tickout{f}}

\newcommand*{\ulinefill}[1]{\xleaders\hbox{\underline{\vphantom{#1}\kern1pt}}\hfill\kern0pt}
\newcommand*{\minwidthbox}[2]{\makebox[{\ifdim#1<\width\width\else#1\fi}]{#2}}

\newcommand*{\fillout}[1]{\allowbreak\hbox{}\nobreak\ulinefill{#1}\underline{\color{blue}\answer{#1}}\ulinefill{#1}}
\newcommand*{\fillin}[1]{\underline{\hspace{1em}\color{blue}\minwidthbox{2em}{\answer{#1}}\hspace{1em}}}

\newcommand*{\pickout}[1]{\unskip\nobreak\cdotfill(\makebox[1.5em]{\color{blue}\answer{#1}})}
\newcommand*{\pickin}[1]{\unskip\nobreak\hspace{0.3em}(\makebox[1.5em]{\color{blue}\answer{#1}})\hspace{0.3em}\ignorespaces}

%% ---------------------------------------------------------------------------
%% 选择题四个选项排版环境，根据四个选项的长度自动排成一行、两行或四行
%% 其中 abcd 环境各列平分整行宽度，而 abcd* 环境各列平分剩余空白
%% ---------------------------------------------------------------------------

\newlength{\my@item@len}
\newlength{\my@label@len}

\newcommand\my@item@temp{%
  \unskip\cr\stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\my@item@box{%
  \hfill\egroup\hfill\hbox to \my@item@len\bgroup
  \stepcounter{choice}(\Alph{choice})\ \ignorespaces
}
\newcommand\my@item@par{%
  \stepcounter{choice}%
  \def\my@label@text{(\Alph{choice})\ }%
  \settowidth{\my@label@len}{\my@label@text}%
  \par \parshape 2 \hanglength \linewidth
  \dimexpr\hanglength + \my@label@len\relax
  \dimexpr\linewidth - \my@label@len\relax
  \my@label@text\ignorespaces
}

\NewEnviron{abcd}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\my@item@temp
  \settowidth{\my@item@len}{\vbox{\halign{##\hfil\cr\BODY\crcr}}}%
  \setcounter{choice}{0}%
  \ifdim\my@item@len>0.486\linewidth
    \setlength{\my@item@len}{\linewidth}%
    \let\item=\my@item@par
    \BODY\par
  \else
    \ifdim\my@item@len>.243\linewidth
      \setlength{\my@item@len}{0.5\linewidth}%
    \else
      \setlength{\my@item@len}{0.25\linewidth}%
    \fi
    \let\item=\my@item@box
    \par\bgroup\BODY\hfill\egroup\par
  \fi
}

\newcommand\my@item@one@line{%
  \unskip
  \ifnumequal{\value{choice}}{0}{}{\hfill}
  \stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\my@item@two@line{%
  \unskip
  \ifnumodd{\value{choice}}{&}{\unskip\cr}%
  \stepcounter{choice}(\Alph{choice})\ %
}

\NewEnviron{abcd*}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\my@item@one@line
  \settowidth{\my@item@len}{\BODY}%
  \ifdim\my@item@len<0.95\linewidth
    \setcounter{choice}{0}%
    \par\bgroup\BODY\hfill\hfill\par\egroup\par
  \else
    \setcounter{choice}{0}%
    \let\item=\my@item@two@line
    \settowidth{\my@item@len}{\vbox{\halign{##&##\hfil\cr\BODY\crcr}}}%
    \ifdim\my@item@len<0.975\linewidth
      \setcounter{choice}{0}%
      \par\bgroup\nointerlineskip
      \vbox{\halign to\linewidth{##\hfil\tabskip=0pt plus 1fil&##\hfil\cr\BODY\crcr}}%
      \egroup\par
    \else
      \setcounter{choice}{0}%
      \let\item=\my@item@par
      \par\bgroup\BODY\hfill\egroup\par
    \fi
  \fi
}

%% ---------------------------------------------------------------------------
%% 设定有序列表使用悬挂缩进，并指定前两级有序列表的标签格式
%% 标签宽度按最宽者自动设定，左边距自动计算，竖直空白全部去掉
%% 最后的 itemjoin 设定行内有序列表 enumerate* 两项之间的空白
%% ---------------------------------------------------------------------------

\setlist[enumerate]{labelindent=0pt,labelsep=0.2em,itemindent=0pt,leftmargin=*,nosep,itemjoin=\quad}
\setlist[enumerate,1]{label=(\arabic*)}
\setlist[enumerate,2]{label=(\alph*),widest*=1}

%% ---------------------------------------------------------------------------
%% 自由对齐命令 \tabpoint, \tabto, \tableft
%% 命令 \tabpoint 记录当前的水平位置，也可以简写为 \?
%% 命令 \tabto 跳到之前记录的位置，也可以简写为 \+
%% 命令 \tableft 跳到之前记录的位置的左侧，也可以简写为 \<
%% 这些自由对齐命令需要编译两次才能生效
%% ---------------------------------------------------------------------------

\usepackage{zref-savepos}

\@ifundefined{zsaveposx}{\let\zsaveposx\zsavepos}{} % 旧版本无 \zsaveposx 命令

\newcounter{saveposcnt}
\newcounter{useposcnt}
\renewcommand*{\thesaveposcnt}{savepos\number\value{saveposcnt}}
\renewcommand*{\theuseposcnt}{usepos\number\value{useposcnt}}

\def\my@alignment@offset{}

\def\my@alignment@list{}
\forcsvlist{\listadd\my@alignment@list}{=,<,>,\le,\ge,\leq,\geq,\approx}

\newlength{\my@alignment@kern}

\newcommand*{\my@alignment@check}[1]{%
  \ifx\my@let@token #1%
    \def\my@alignment@offset{5}%
    \listbreak
  \fi
}

\newcommand{\my@alignment@next}{%
  \ifdefempty{\my@alignment@offset}{%
    \def\my@alignment@offset{0}%
    \forlistloop{\my@alignment@check}{\my@alignment@list}%
  }{}%
  \settowidth{\my@alignment@kern}{$\mkern\my@alignment@offset mu$}%
  \stepcounter{saveposcnt}%
  \rlap{\kern\my@alignment@kern\zsaveposx{\thesaveposcnt}}%
}

\newcommand*{\tabpoint}[1][]{%
  \leavevmode
  \def\my@alignment@offset{#1}%
  \futurelet\my@let@token\my@alignment@next
}
\let \? = \tabpoint

\newcommand*{\tabto}{%
  \stepcounter{useposcnt}%
  \zsaveposx{\theuseposcnt}%
  \noindent
  \hskip\zposx{\thesaveposcnt}sp\relax
  \hskip-\zposx{\theuseposcnt}sp\relax
  \ignorespaces
}
\let \+ = \tabto

\newcommand*{\tableft}{%
  \settowidth{\my@alignment@kern}{$=\mkern5mu$}%
  \stepcounter{useposcnt}%
  \zsaveposx{\theuseposcnt}%
  \noindent
  \hskip\zposx{\thesaveposcnt}sp\relax
  \hskip-\zposx{\theuseposcnt}sp\relax
  \hskip-\my@alignment@kern
  \ignorespaces
}
\let \< = \tableft

%% ---------------------------------------------------------------------------
%% 评分命令 \points
%% ---------------------------------------------------------------------------

\PassOptionsToPackage{tbtags}{amsmath}
\RequirePackage{amsmath}

\newcommand{\mypoints}[1]{\textcolor{red}{#1\kern0.15em 分}}

\newcommand{\pointstext}[1]{\mbox{}\nobreak\hfill$\cdots\cdots$\mypoints{#1}\par\noindent\ignorespaces}
\newcommand{\pointseqno}[1]{\eqno{\cdots\cdots\text{\mypoints{#1}}}}
\newcommand{\pointstag}[1]{\tag*{$\cdots\cdots$\mypoints{#1}}}

\newrobustcmd{\points}[1]{%
  \ifbool{mmode}{%
    \ifdefstrequal{\tag}{\dft@tag}{\pointseqno{#1}}{\pointstag{#1}}%
  }{%
    \pointstext{#1}%
  }%
}
\let\score=\points % \score 命令已经废弃，不要再使用

%% ---------------------------------------------------------------------------
%% 载入个人定制文件 jnuexam.cfg
%% 中文字体切换选项 sourcehan
%% ---------------------------------------------------------------------------

\InputIfFileExists{jnuexam.cfg}{}{}

\newcommand{\my@set@sourcehan}{
  \setCJKmainfont[BoldFont=Source Han Sans SC]{Source Han Serif SC}
  \setCJKsansfont{Source Han Sans SC}
  % 用中文字体名时 LuaTeX 找不到该字体，XeTeX 正常
  %\setCJKmainfont[BoldFont=思源黑体]{思源宋体}
  %\setCJKsansfont{思源黑体}
}

\AtBeginDocument{%
  \ifbool{sourcehan}{%
    % https://sourceforge.net/p/xetex/code/ci/master/tree/source/texk/web2c/xetexdir/NEWS
    \ifbool{XeTeX}{% TeXLive 2015
      \ifdimless{\the\XeTeXversion\XeTeXrevision pt}{0.99992pt}{}{\my@set@sourcehan}%
    }{}%
    \ifbool{LuaTeX}{\my@set@sourcehan}{}%
  }{}%
}

%% ---------------------------------------------------------------------------
%% 在 tabular 和 array 等表格环境中添加列间距
%% 避免单元格里出现的分式太过接近上面和下面行
%% ---------------------------------------------------------------------------

\newcommand{\my@do@cellspace}{%
  \RequirePackage[math]{cellspace}%
  \setlength\cellspacetoplimit{2pt}%
  \setlength\cellspacebottomlimit{2pt}%
  \addparagraphcolumntypes{X}%
  \newcolumntype{0}[1]{>{\bcolumn ##1\@nil}##1<{\ecolumn}}%
  \newcolumntype{5}[1]{>{$}0{##1}<{$}}%
  % Fix cellspace bug before version 1.7
  % See https://tex.stackexchange.com/a/385581
  \@ifpackagelater{cellspace}{2017/08/12}{}{%
    \patchcmd{\@endpbox}{\color@endgroup}{\expandafter\color@endgroup}{}{}%
  }%
}

\AtBeginDocument{%
  \ifcellspace \my@do@cellspace \fi
}

%% ---------------------------------------------------------------------------
%% 统一行间公式和行内公式的巨算符和分式的尺寸
%% 利用开头的 medmath 选项可以启用此部分设定
%% ---------------------------------------------------------------------------

\newcommand{\my@do@medmath}{%
  \RequirePackage[mediummath]{nccmath}%
  %% 补充 \oiint 命令的调整
  \ifdef{\oiint}{%
    \let\NCC@op@oiint=\oiint
    \DeclareRobustCommand{\oiintop}{\mathop{\medmath{\NCC@op@oiint}}}%
    \def\oiint{\DOTSI\NCC@op@prepare{\oiintop}}%
  }{}%
  %% 设定 nccmath 的积分号校正尺寸
  %% 后面已经改用相对尺寸，不再需要
  %\ifamsfonts
  %  \medintcorr{0.5em}
  %\else
  %  \medintcorr{0.3em}
  %\fi
  %% 使用 nccmath 宏包后，cases 环境包含定积分时将无法编译，这里重新定义此环境
  %% 注意相比 amsmath 的原始定义，我们这里将 \quad 从两列之间移动到第二列最前面
  %% 这是因为，我们常将 cases 用于只有一列的方程组，这样处理末尾不会有多余空白
  \ifbool{cellspace}{%
    \renewenvironment{cases}{%
      \left\{\linespread{1.0}\selectfont\def\arraystretch{1.2}%
      \begin{array}{@{}5l@{}>{\quad}5l@{}}%
    }{%
      \end{array}\right.%
    }%
  }{%
    \renewenvironment{cases}{%
      \left\{\linespread{1.0}\selectfont\def\arraystretch{1.2}%
      \begin{array}{@{}l@{}>{\quad}l@{}}%
    }{%
      \end{array}\right.%
    }%
  }
  %% 当 minipage 或 \parbox 仅包含行间公式时，盒子的右边距丢失，这里修正它
  %% 其他类似问题的描述见 http://tex.stackexchange.com/q/22170
  \let\start@gather=\NCC@startgather
  \let\start@align=\NCC@startalign
  \let\start@multline=\NCC@startmultline
  \let\mathdisplay=\NCC@startdisplay
}

\newcommand{\my@do@medmath@fix}{%
  %% 修正在角标处的非积分巨算符尺寸
  %% 参考了 scalerel 宏包对数学样式的保存方法
  % 非角标巨算符保持为 \displaystyle 巨算符的 80% 大小
  % 一级角标巨算符修改为 \textstyle 巨算符的 80% 大小
  % 二级角标巨算符修改为 \scriptstyle 巨算符的 80% 大小
  \def\@my@style@D{\displaystyle}%
  \def\@my@style@T{\displaystyle}%
  \def\@my@style@S{\textstyle}%
  \def\@my@style@s{\scriptstyle}%
  \def\my@style@saved{\csname @my@style@\@my@style@switch\endcsname}%
  \newcommand{\my@style@this}[1]{%
    \mathchoice{\def\@my@style@switch{D}##1}{\def\@my@style@switch{T}##1}
               {\def\@my@style@switch{S}##1}{\def\@my@style@switch{s}##1}%
  }%
  \DeclareRobustCommand*\medmath[1]{\NCC@select@msize
    \mathord{\my@style@this{\raise\@tempdima\hbox{\NCC@prepare@msize$\my@style@saved ##1$}}}%
  }
  %% 修正在角标处的积分算符尺寸和上下限位置
  \newlength{\@my@em}%
  \setlength{\@my@em}{1em}%
  \ifamsfonts
    \medintcorr{0.5\@my@em}%
  \else
    \medintcorr{0.3\@my@em}%
  \fi
  \newcommand{\my@style@unit}[1]{%
    \mathchoice{\setlength{\@my@em}{1em}##1}{\setlength{\@my@em}{1em}##1}
               {\setlength{\@my@em}{0.5em}##1}{\setlength{\@my@em}{0.3em}##1}%
  }%
  \let\my@saved@op@printm=\NCC@op@printm
  \def\NCC@op@printm{\my@style@unit{\my@saved@op@printm}}%
  %% 修正在角标位置的分式和嵌套分式
  %% 总是使用当前样式尺寸来排版分式的分子和分母
  \newcommand{\my@larger@frac}[2]{%
    \mathchoice{\genfrac{}{}{}{0}{##1}{##2}}{\genfrac{}{}{}{0}{##1}{##2}}%
               {\genfrac{}{}{}{1}{##1}{##2}}{\genfrac{}{}{}{2}{##1}{##2}}%
  }%
  \DeclareRobustCommand{\frac}[2]{%
    \mathchoice{\mfrac{##1}{##2}}{\mfrac{##1}{##2}}%
               {\my@larger@frac{##1}{##2}}{\my@larger@frac{##1}{##2}}%
  }%
  \patchcmd{\NCC@prepare@msize}{%
    \def\frac{\protect\NCC@innerfrac{}}%
  }{%
    \let\frac=\my@larger@frac
  }{}{}%
}

\AtBeginDocument{%
  \ifmedmath
    \my@do@medmath \my@do@medmath@fix
  \fi
}

%% ---------------------------------------------------------------------------
%% 载入常用宏包，定义常用命令
%% ---------------------------------------------------------------------------

\AtBeginDocument{
  \setlength{\abovedisplayskip}{4pt minus 2pt}
  \setlength{\belowdisplayskip}{4pt minus 2pt}
  \setlength{\abovedisplayshortskip}{2pt}
  \setlength{\belowdisplayshortskip}{2pt}
}

\setlength\arraycolsep{4pt}

\ifbool{XeTeX}{
  % https://en.wikipedia.org/wiki/Number_Forms
  % Ⅰ、Ⅱ、Ⅲ、Ⅳ、Ⅴ、Ⅵ、Ⅶ、Ⅷ、Ⅸ、Ⅹ、Ⅺ、Ⅻ
  \xeCJKsetcharclass{"2150}{"218F}{1} % 斜线分数，全角罗马数字等
  % https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
  \xeCJKsetcharclass{"2460}{"24FF}{1} % 带圈数字字母，括号数字字母，带点数字等
}{}

\RequirePackage{multirow}
\RequirePackage{tabu}

\RequirePackage{diagbox}
%% 修正 \diagbox 在 array 环境中使用的问题
\newrobustcmd{\diagboxtwo}[3][]{%
  \ifbool{mmode}{%
    \hbox{\let\tabcolsep=\arraycolsep\diagbox[#1]{$#2$}{$#3$}}%
  }{%
    \diagbox[#1]{#2}{#3}%
  }
}
\newrobustcmd{\diagboxthree}[4][]{%
  \ifbool{mmode}{%
    \hbox{\let\tabcolsep=\arraycolsep\diagbox[#1]{$#2$}{$#3$}{$#4$}}%
  }{%
    \diagbox[#1]{#2}{#3}{#4}%
  }
}

\RequirePackage{mathtools} % \mathllap 命令，pmatrix* 环境等
\RequirePackage{extarrows}

\RequirePackage{relsize}
\newcommand{\Int}{\mathop{\mathlarger{\int}}}

\AtBeginDocument{%
  \let\my@saved@lim=\lim    \def\lim{\my@saved@lim\limits}%
  \let\my@saved@sum=\sum    \def\sum{\my@saved@sum\limits}%
  \let\my@saved@prod=\prod  \def\prod{\my@saved@prod\limits}%
}
\newcommand{\limit}{\lim\limits} % 废弃命令，不要再使用

\newcommand{\e}{\mathrm{e}}
\newcommand{\R}{\mathbb{R}}

\DeclareMathOperator{\arccot}{arccot}
\DeclareMathOperator{\Corr}{\rho}
\DeclareMathOperator{\Cov}{Cov}
\DeclareMathOperator{\diag}{diag}
\DeclareMathOperator{\grad}{grad}
\DeclareMathOperator{\Prj}{Prj}
\DeclareMathOperator{\tr}{tr}
\DeclareMathOperator{\Var}{Var}

\DeclareMathOperator{\diver}{div}
\let\division=\div
\let\div=\diver

\newcommand{\diff}{\mathop{}\!\mathrm{d}}
\newcommand{\dx}{\diff x}
\newcommand{\dy}{\diff y}
\def\dz{\diff z} % 不确定命令是否已经定义
\newcommand{\du}{\diff u}
\newcommand{\dv}{\diff v}
\newcommand{\dr}{\diff r}
\newcommand{\ds}{\diff s}
\newcommand{\dt}{\diff t}
\newcommand{\dS}{\diff S}
% 有些宏包比如 hyperref 会修改 \d 的定义，所以放在 document 开始处
% 利用 etoolbox 将 \d 定义为健壮命令，以避免在 align 等环境中错误地展开
\AtBeginDocument{%
  \let\oldd=\d
  \renewrobustcmd{\d}{\ifbool{mmode}{\diff}{\oldd}}%
}

\let\pd=\partial
\newcommand{\pdf}{\pd f}
\newcommand{\pdg}{\pd g}
\newcommand{\pdh}{\pd h}
\newcommand{\pdl}{\pd l}
\newcommand{\pdn}{\pd n}
\newcommand{\pdu}{\pd u}
\newcommand{\pdv}{\pd v}
\newcommand{\pdx}{\pd x}
\newcommand{\pdy}{\pd y}
\newcommand{\pdz}{\pd z}
\newcommand{\pdF}{\pd F}
\newcommand{\pdL}{\pd L}
\newcommand{\pdP}{\pd P}
\newcommand{\pdQ}{\pd Q}
\newcommand{\pdR}{\pd R}

% from mathabx package
\DeclareFontFamily{U}{mathx}{\hyphenchar\font45}
\DeclareFontShape{U}{mathx}{m}{n}{<-> mathx10}{}
\DeclareSymbolFont{mathx}{U}{mathx}{m}{n}
\DeclareMathAccent{\widebar}{0}{mathx}{"73}

\newcommand{\va}{\vec{a}}
\newcommand{\vb}{\vec{b}}
\newcommand{\vc}{\vec{c}}
\newcommand{\vd}{\vec{d}}
\newcommand{\ve}{\vec{e}}
\newcommand{\vi}{\vec{i}}
\newcommand{\vj}{\vec{j}}
\newcommand{\vk}{\vec{k}}
\newcommand{\vn}{\vec{n}}
\newcommand{\vs}{\vec{s}}
\newcommand{\vv}{\vec{v}}

\let\ov=\overrightarrow

\let\le=\leqslant
\let\ge=\geqslant

\let\lb=\{
\let\rb=\}

\def\T{\mathrm{T}\kern-.5pt}

% 分数线长一点的分数，\wfrac[2pt]{x}{y} 表示左右加 2pt
% 和前面的 medmath 一样，将代码放在 \AtBeginDocument 里
\AtBeginDocument{%
  \newrobustcmd{\wfrac}[3][2pt]{%
    \frac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
  \newrobustcmd{\wdfrac}[3][2pt]{%
    \dfrac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
  \newrobustcmd{\wtfrac}[3][2pt]{%
    \tfrac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
}

