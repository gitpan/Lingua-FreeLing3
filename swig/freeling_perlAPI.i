//////////////////////////////////////////////////////////////////
//
//    FreeLing - Open Source Language Analyzers
//
//    Copyright (C) 2004   TALP Research Center
//                         Universitat Politecnica de Catalunya
//
//    This library is free software; you can redistribute it and/or
//    modify it under the terms of the GNU General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    General Public License for more details.
//
//    You should have received a copy of the GNU General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
//    contact: Lluis Padro (padro@lsi.upc.es)
//             TALP Research Center
//             despatx C6.212 - Campus Nord UPC
//             08034 Barcelona.  SPAIN
//
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//
//  freeling_perlAPI.i
//  This is the SWIG input file, used to generate perl/pyhton/java APIs.
//
////////////////////////////////////////////////////////////////

%module "Lingua::FreeLing3::Bindings"
%{
 #include "freeling.h"
 #include "freeling/tree.h"
 #include "freeling/morfo/traces.h"
 using namespace std;
%}

#%include "std_string.i"

### Typemaps ###

%typemap(in) const std::wstring & (std::wstring wtemp)  {
  std::string aux (SvPV($input, PL_na));
  wtemp = util::string2wstring(aux);
  $1 = &wtemp;
}

%typemap(in) std::wstring (std::wstring wtemp) {
  std::string aux (SvPV($input, PL_na));
  wtemp = util::string2wstring(aux);
  $1 = wtemp;
}


%typemap(out)  const std::wstring & {
  std::string temp;
  temp = util::wstring2string($1);
  $result = newSVpv(temp.c_str(), 0);
  argvi++;
  SvUTF8_on ($result);
}

%typemap(out) std::wstring = const std::wstring &;

%typemap(typecheck) const std::wstring & = char *;

%include std_list.i
%include std_vector.i
%include std_map.i

%template(VectorWord) std::vector<word>;
%template(ListWord) std::list<word>;
%template(ListAnalysis) std::list<analysis>;
%template(ListSentence) std::list<sentence>;
%template(ListParagraph) std::list<paragraph>;

%template(ListString) std::list<std::wstring>;
%template(ListInt) std::list<int>;
%template(VectorListInt) std::vector<std::list<int> >;
%template(VectorListString) std::vector<std::list<std::wstring> >;


############### MORFO #####################

// forward declarations
template <class T> class tree;
template <class T> class preorder_iterator;

template<class T>
class generic_iterator  {
 protected:
  tree<T> *pnode;
 public:
  generic_iterator();
  generic_iterator(const generic_iterator<T> &);
  generic_iterator(tree<T> *);
  tree<T>& operator*() const;
  tree<T>* operator->() const;
  bool operator==(const generic_iterator &) const;
  bool operator!=(const generic_iterator &) const;
};


/// traverse all children of the same node
template<class T>
class sibling_iterator : public generic_iterator<T> {
  friend class preorder_iterator<T>;
 public:
  sibling_iterator();
  sibling_iterator(const sibling_iterator<T> &);
  sibling_iterator(tree<T> *);

  sibling_iterator& operator++();
  sibling_iterator& operator--();
  sibling_iterator& operator+=(unsigned int);
  sibling_iterator& operator-=(unsigned int);
};

/// traverse the tree in preorder (parent first, then children)
template<class T>
class preorder_iterator : public generic_iterator<T> {
 public:
  preorder_iterator();
  preorder_iterator(const preorder_iterator<T> &);
  preorder_iterator(tree<T> *);
  preorder_iterator(sibling_iterator<T> &);

  preorder_iterator& operator++();
  preorder_iterator& operator--();
  preorder_iterator& operator+=(unsigned int);
  preorder_iterator& operator-=(unsigned int);
};


template <class T> class tree {
  friend class preorder_iterator<T>;
  friend class sibling_iterator<T>;
 public:
  T info;
  typedef class generic_iterator<T> generic_iterator;
  typedef class preorder_iterator<T> preorder_iterator;
  //  class const_preorder_iterator;
  typedef class sibling_iterator<T> sibling_iterator;
  // class const_sibling_iterator;
  typedef preorder_iterator iterator;

  tree();
  tree(const T&);
  tree(const tree<T>&);
  tree(const preorder_iterator&);
  ~tree();
  ##tree<T>& operator=(const tree<T>&);

  unsigned int num_children() const;
  sibling_iterator nth_child(unsigned int) const;
  tree<T>& nth_child_ref(unsigned int) const;
  T& get_info();
  void append_child(const tree<T> &);
  void hang_child(tree<T> &);
  void clear();
  bool empty() const;

  sibling_iterator sibling_begin();
  sibling_iterator sibling_end() const;

  preorder_iterator begin();
  preorder_iterator end() const;
};

%template(GenericIteratorNode) generic_iterator<node>;
%template(PreorderIteratorNode) preorder_iterator<node>;
%template(SiblingIteratorNode) sibling_iterator<node>;

%template(GenericIteratorDepnode) generic_iterator<depnode>;
%template(PreorderIteratorDepnode) preorder_iterator<depnode>;
%template(SiblingIteratorDepnode) sibling_iterator<depnode>;

%template(TreeNode) tree<node>;
%template(TreeDepnode) tree<depnode>;
%rename(operator_assignment) operator=;


class analysis {
   public:
      /// user-managed data, we just store it.
      std::vector<std::wstring> user;

      /// constructor
      analysis();
      /// constructor
      analysis(const std::wstring &, const std::wstring &);
      /// assignment
      analysis& operator=(const analysis&);

      void set_lemma(const std::wstring &);
      void set_tag(const std::wstring &);
      void set_prob(double);
      void set_distance(double);
      void set_retokenizable(const std::list<word> &);

      bool has_prob() const;
      bool has_distance() const;
      std::wstring get_lemma() const;
      std::wstring get_tag() const;
      std::wstring get_short_tag() const;
      std::wstring get_short_tag(const std::wstring &) const;
      double get_prob() const;
      double get_distance() const;
      bool is_retokenizable() const;
      std::list<word> get_retokenizable() const;

      std::list<std::pair<std::wstring,double> > get_senses() const;
      void set_senses(const std::list<std::pair<std::wstring,double> > &);
      // useful for java API
      std::wstring get_senses_string() const;

      /// Comparison to sort analysis by *decreasing* probability
      bool operator<(const analysis &) const;
      /// Comparison (to please MSVC)
      bool operator==(const analysis &) const;
};


////////////////////////////////////////////////////////////////
///   Class word stores all info related to a word: 
///  form, list of analysis, list of tokens (if multiword).
////////////////////////////////////////////////////////////////

class word : public std::list<analysis> {
   public:
      /// user-managed data, we just store it.
      std::vector<std::wstring> user;

      /// constructor
      word();
      /// constructor
      word(const std::wstring &);
      /// constructor
      word(const std::wstring &, const std::list<word> &);
      /// constructor
      word(const std::wstring &, const std::list<analysis> &, const std::list<word> &);
      /// Copy constructor
      word(const word &);
      /// assignment
      word& operator=(const word&);

      /// copy analysis from another word
      void copy_analysis(const word &);
      /// Get the number of selected analysis
      int get_n_selected() const;
      /// get the number of unselected analysis
      int get_n_unselected() const;
      /// true iff the word is a multiword compound
      bool is_multiword() const;
      /// get number of words in compound
      int get_n_words_mw() const;
      /// get word objects that compound the multiword
      std::list<word> get_words_mw() const;
      /// get word form
      std::wstring get_form() const;
      /// Get word form, lowercased.
      std::wstring get_lc_form() const;
      /// Get an iterator to the first selected analysis
      word::iterator selected_begin();
      /// Get an iterator to the first selected analysis
      word::const_iterator selected_begin() const;
      /// Get an iterator to the end of selected analysis list
      word::iterator selected_end();
      /// Get an iterator to the end of selected analysis list
      word::const_iterator selected_end() const;
      /// Get an iterator to the first unselected analysis
      word::iterator unselected_begin();
      /// Get an iterator to the first unselected analysis
      word::const_iterator unselected_begin() const;
      /// Get an iterator to the end of unselected analysis list
      word::iterator unselected_end();
      /// Get an iterator to the end of unselected analysis list
      word::const_iterator unselected_end() const;
      /// get lemma for the selected analysis in list
      std::wstring get_lemma() const;
      /// get tag for the selected analysis
      std::wstring get_tag() const;
      /// get tag (short version) for the selected analysis, assuming eagles tagset
      std::wstring get_short_tag() const;
      /// get tag (short version) for the selected analysis
      std::wstring get_short_tag(const std::wstring &) const;

      /// get sense list for the selected analysis
      std::list<std::pair<std::wstring,double> > get_senses() const;
      // useful for java API
      std::wstring get_senses_string() const;
      /// set sense list for the selected analysis
      void set_senses(const std::list<std::pair<std::wstring,double> > &);

      /// get token span.
      unsigned long get_span_start() const;
      unsigned long get_span_finish() const;

      /// get in_dict
      bool found_in_dict() const;
      /// set in_dict
      void set_found_in_dict(bool);
      /// check if there is any retokenizable analysis
      bool has_retokenizable() const;
      /// mark word as having definitive analysis
      void lock_analysis();
      /// check if word is marked as having definitive analysis
      bool is_locked() const;

      /// add an alternative to the alternatives list
      void add_alternative(const word &, double);
      /// replace alternatives list with list given
      void set_alternatives(const std::list<std::pair<word,double> > &);
      /// find out if the speller checked alternatives
      bool has_alternatives() const;
      /// get alternatives list
      std::list<std::pair<word,double> > get_alternatives() const;
      /// get alternatives begin iterator
      std::list<std::pair<word,double> >::iterator alternatives_begin();
      /// get alternatives end iterator
      std::list<std::pair<word,double> >::iterator alternatives_end();

      /// add one analysis to current analysis list  (no duplicate check!)
      void add_analysis(const analysis &);
      /// set analysis list to one single analysis, overwriting current values
      void set_analysis(const analysis &);
      /// set analysis list, overwriting current values
      void set_analysis(const std::list<analysis> &);
      /// set word form
      void set_form(const std::wstring &);
      /// set token span
      void set_span(unsigned long, unsigned long);

      /// look for an analysis with a tag matching given regexp
      bool find_tag_match(boost::u32regex &);

      /// get number of analysis in current list
      int get_n_analysis() const;
      /// empty the list of selected analysis
      void unselect_all_analysis();
      /// mark all analysisi as selected
      void select_all_analysis();
      /// add the given analysis to selected list.
      void select_analysis(word::iterator);
      /// remove the given analysis from selected list.
      void unselect_analysis(word::iterator);
      /// get list of analysis (useful for perl API)
      std::list<analysis> get_analysis() const;
      /// get begin iterator to analysis list (useful for perl/java API)
      word::iterator analysis_begin();
      word::const_iterator analysis_begin() const;
      /// get end iterator to analysis list (useful for perl/java API)
      word::iterator analysis_end();
      word::const_iterator analysis_end() const;
};

////////////////////////////////////////////////////////////////
///   Class parse tree is used to store the results of parsing
///  Each node in the tree is either a label (intermediate node)
///  or a word (leaf node)
////////////////////////////////////////////////////////////////

class node {
  public:
    /// constructors
    node();
    node(const std::wstring &);
    /// get node identifier
    std::wstring get_node_id() const;
    /// set node identifier
    void set_node_id(const std::wstring &);
    /// get node label
    std::wstring get_label() const;
    /// get node word
    word get_word() const;
    /// set node label
    void set_label(const std::wstring &);
    /// set node word
    void set_word(word &);
    /// find out whether node is a head
    bool is_head() const;
    /// set whether node is a head
    void set_head(const bool);
    /// find out whether node is a chunk
    bool is_chunk() const;
    /// set position of the chunk in the sentence
    void set_chunk(const int);
    /// get position of the chunk in the sentence
    int  get_chunk_ord() const;
};

class parse_tree : public tree<node> {
  public:
    parse_tree();
    parse_tree(const node &);
};


////////////////////////////////////////////////////////////////
/// class denode stores nodes of a dependency tree and
///  parse tree <-> deptree relations
////////////////////////////////////////////////////////////////

class depnode : public node {
  public:
    depnode();
    depnode(const std::wstring &);
    depnode(const node &);
    void set_link(const parse_tree::iterator);
    parse_tree::iterator get_link(void);
    tree<node>& get_link_ref(void);
    void set_label(const std::wstring &);
};

////////////////////////////////////////////////////////////////
/// class dep_tree stores a dependency tree
////////////////////////////////////////////////////////////////

class dep_tree :  public tree<depnode> {
  public:
    dep_tree();
    dep_tree(const depnode &);
};


////////////////////////////////////////////////////////////////
///   Class sentence is just a list of words that someone
/// (the splitter) has validated it as a complete sentence.
/// It may include a parse tree.
////////////////////////////////////////////////////////////////

class sentence : public std::list<word> {
 public:
  sentence();
  
  void set_parse_tree(const parse_tree &);
  parse_tree & get_parse_tree(void);
  bool is_parsed() const;  
  dep_tree & get_dep_tree();
  void set_dep_tree(const dep_tree &);
  bool is_dep_parsed() const;
  /// get word list (useful for perl API)
  std::vector<word> get_words() const;
  /// get iterators to word list (useful for perl/java API)
  sentence::iterator words_begin(void);
  sentence::const_iterator words_begin(void) const;
  sentence::iterator words_end(void);
  sentence::const_iterator words_end(void) const;
};

////////////////////////////////////////////////////////////////
///   Class paragraph is just a list of sentences that someone
///  has validated it as a paragraph.
////////////////////////////////////////////////////////////////

class paragraph : public std::list<sentence> {};

////////////////////////////////////////////////////////////////
///   Class document is a list of paragraphs. It may have additional 
///  information (such as title)
////////////////////////////////////////////////////////////////

class document : public std::list<paragraph> {
 public:
    document();
    void add_positive(std::wstring, std::wstring);
    int get_coref_group(std::wstring) const;
    std::list<std::wstring> get_coref_nodes(int) const;
    bool is_coref(std::wstring, std::wstring) const;
};



###############  FREELING  #####################

class traces {
 public:
    // current trace level
    static int TraceLevel;
    // modules to trace
    static unsigned long TraceModule;
};


/*------------------------------------------------------------------------*/
class tokenizer {
   public:
       /// Constructor
       tokenizer(const std::wstring &);

       /// tokenize wstring with default options
       std::list<word> tokenize(const std::wstring &);
       /// tokenize wstring with default options, tracking offset in given int param.
       std::list<word> tokenize(const std::wstring &, unsigned long &);
};

/*------------------------------------------------------------------------*/
class splitter {
   public:
      /// Constructor
      splitter(const std::wstring &);

      /// split sentences with default options
      std::list<sentence> split(const std::list<word> &, bool);
};


/*------------------------------------------------------------------------*/
class maco_options {
 public:
    // Language analyzed
    std::wstring Lang;

    /// Morhpological analyzer active modules.
    bool AffixAnalysis,   MultiwordsDetection, 
         NumbersDetection, PunctuationDetection, 
         DatesDetection,   QuantitiesDetection, 
         DictionarySearch, ProbabilityAssignment,
         OrthographicCorrection, UserMap;
    int NERecognition;

    /// Morphological analyzer modules configuration/data files.
    std::wstring LocutionsFile, QuantitiesFile, AffixFile, 
           ProbabilityFile, DictionaryFile, 
           NPdataFile, PunctuationFile,
           CorrectorFile, UserMapFile;

    /// module-specific parameters for number recognition
    std::wstring Decimal, Thousand;
    /// module-specific parameters for probabilities
    double ProbabilityThreshold;
    /// module-specific parameters for dictionary
    bool InverseDict,RetokContractions;

    /// constructor
    maco_options(const std::wstring &);

    /// Option setting methods provided to ease perl interface generation. 
    /// Since option data members are public and can be accessed directly
    /// from C++, the following methods are not necessary, but may become
    /// convenient sometimes.
    void set_active_modules(bool,bool,bool,bool,bool,bool,bool,bool,bool,bool,bool);
    void set_data_files(const std::wstring &,const std::wstring &,const std::wstring &,
                        const std::wstring &,const std::wstring &,const std::wstring &,
                        const std::wstring &,const std::wstring &, const std::wstring &);

    void set_nummerical_points(const std::wstring &,const std::wstring &);
    void set_threshold(double);
    void set_inverse_dict(bool);
    void set_retok_contractions(bool);
};

/*------------------------------------------------------------------------*/
class maco {
   public:
      /// Constructor
      maco(const maco_options &);

      /// analyze sentences
      std::list<sentence> analyze(const std::list<sentence> &);
};


/*------------------------------------------------------------------------*/
class hmm_tagger {
   public:
       /// Constructor
       hmm_tagger(const std::wstring &, const std::wstring &, bool, unsigned int);

       /// analyze sentences
       void analyze(std::list<sentence> &);
       /// analyze sentences, return copy
       std::list<sentence> analyze(const std::list<sentence> &);
};


/*------------------------------------------------------------------------*/
class relax_tagger {
   public:
       /// Constructor, given the constraints file and config parameters
       relax_tagger(const std::wstring &, int, double, double, bool, unsigned int);

       /// analyze sentences
       void analyze(std::list<sentence> &);
       /// analyze sentences, return copy
       std::list<sentence> analyze(const std::list<sentence> &);
};


/*------------------------------------------------------------------------*/
class nec {
   public:
      /// Constructor
      nec(const std::wstring &); 
      /// Destructor
      ~nec();

      /// Classify NEs in given sentence
      void analyze(std::list<sentence> &);
      /// analyze sentences, return copy
      std::list<sentence> analyze(const std::list<sentence> &);
};


/*------------------------------------------------------------------------*/
class chart_parser {
 public:
   /// Constructors
   chart_parser(const std::wstring&);
   /// Get the start symbol of the grammar
   std::wstring get_start_symbol(void) const;
   /// parse sentences in list
   void analyze(std::list<sentence> &);
   /// analyze sentences, return copy
   std::list<sentence> analyze(const std::list<sentence> &);
};

/*------------------------------------------------------------------------*/
class dependency_parser {
  public: 
   dependency_parser();
   virtual ~dependency_parser() {};
   virtual void analyze(std::list<sentence> &)=0;
};


/*------------------------------------------------------------------------*/
class dep_txala : public dependency_parser {
 public:   
   dep_txala(const std::wstring &, const std::wstring &);
   void analyze(std::list<sentence> &);
   /// analyze sentences, return copy
   std::list<sentence> analyze(const std::list<sentence> &);
};



/*------------------------------------------------------------------------*/
class senses {
   public:
      /// Constructor
      senses(const std::wstring &); 
      /// Destructor
      ~senses(); 
 
      /// sense annotate selected analysis for each word in given sentences
      void analyze(std::list<sentence> &);
      /// analyze sentences, return copy
      std::list<sentence> analyze(const std::list<sentence> &);
};


/*------------------------------------------------------------------------*/
class ukb_wrap {
   public:
      /// Constructor
      ukb_wrap(const std::wstring &);
      /// Destructor
      ~ukb_wrap();
      /// word sense disambiguation for each word in given sentences
      void analyze(std::list<sentence> &);
      /// Return annotated copy (useful for perl/python/java APIs)
      std::list<sentence> analyze(const std::list<sentence> &);      
};


/*------------------------------------------------------------------------*/
class sense_info {
 public:
  /// sense code
  std::wstring sense;
  /// hyperonyms
  std::list<std::wstring> parents;
  /// WN semantic file code
  std::wstring semfile;
  /// list of synonyms (words in the synset)
  std::list<std::wstring> words;
  /// list of EWN top ontology properties
  std::list<std::wstring> tonto;

  /// constructor
  sense_info(const std::wstring &,const std::wstring &);
  std::wstring get_parents_string() const;
};


////////////////////////////////////////////////////////////////
/// Class semanticDB implements a semantic DB interface
////////////////////////////////////////////////////////////////

class semanticDB {

   public:
      /// Constructor
      semanticDB(const std::wstring &);
      /// Destructor
      ~semanticDB();

      /// Compute list of lemma-pos to search in WN for given word, according to mapping rules.
      void get_WN_keys(const std::wstring &, const std::wstring &, const std::wstring &, std::list<std::pair<std::wstring,std::wstring> > &) const;
      /// get list of words for a sense
      std::list<std::wstring> get_sense_words(const std::wstring &) const;
      /// get list of senses for a lemma+pos
      std::list<std::wstring> get_word_senses(const std::wstring &, const std::wstring &, const std::wstring &) const;
      /// get sense info for a sense
      sense_info get_sense_info(const std::wstring &) const;
};

class util {
 public:
   /// Init the locale of the program, to properly handle unicode
   static void init_locale(const std::wstring &);
};


%perlcode %{


__END__

=encoding utf8

=head1 NAME

 Lingua::FreeLing2::Bindings - Bindings to FreeLing library.

=head1 DESCRIPTION

This module is the base for the bindings between Perl and the C++
library, FreeLing. It was generated by Jorge Cunha Mendes, using as
base the module provided in the FreeLing distribution.

Given the high amount of modules and methods, the bindings are not
practical to be used directly. Therefore, C<Lingua::FreeLing>
encapsulates the binding behavior in more Perlish interfaces.

Please refer to L<Lingua::FreeLing> for the documentation table of
contents, and try not to use this module directly. You can always
request the authors an interface to any of these methods to be added
in the main modules.

=head1 SEE ALSO

Lingua::FreeLing2(3) for the documentation table of contents. The
freeling library for extra information, or perl(1) itself.

=head1 AUTHOR

Lluís Padró

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 by Projecto Natura

=cut

%}
